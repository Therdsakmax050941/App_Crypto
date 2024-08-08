import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';

class TopCrypto extends StatefulWidget {
  @override
  _TopCryptoState createState() => _TopCryptoState();
}

class _TopCryptoState extends State<TopCrypto> {
  late WebSocketChannel _channel;
  Map<String, List<PriceData>> _cryptoPrices = {};
  Map<String, Color> _priceColors = {}; // Store color for each symbol
  List<String> _cryptoSymbols = [
    'btcusdt', 'ethusdt', 'xrpusdt', 'ltcusdt', 'adausdt', 'dotusdt',
    'xlmusdt', 'linkusdt', 'bnbusdt', 'usdtusdt', 'solusdt', 'dogeusdt',
    'shibusdt', 'maticusdt', 'aaveusdt', 'uniusdt', 'xemusdt', 'ftmusdt',
    'ltcusdt', 'chzusdt', 'lunausdt'
  ];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://stream.binance.com:9443/stream?streams=${_cryptoSymbols.map((symbol) => symbol + '@trade').join('/')}')
    );
    
    _channel.stream.listen((data) {
      final message = json.decode(data);
      final streamName = message['stream'];
      final rawPayload = message['data'];

      final symbol = rawPayload['s'].toLowerCase();
      final price = double.tryParse(rawPayload['p'].toString()) ?? 0.0;

      setState(() {
        if (!_cryptoPrices.containsKey(symbol)) {
          _cryptoPrices[symbol] = [];
          _priceColors[symbol] = Colors.white;
        }

        final prices = _cryptoPrices[symbol]!;
        prices.add(PriceData(DateTime.now(), price));
        if (prices.length > 10) {
          prices.removeAt(0);
        }

        // Check price movement and set color accordingly
        if (prices.length > 1) {
          final previousPrice = prices[prices.length - 2].price;
          if (price > previousPrice) {
            _priceColors[symbol] = Colors.green;
          } else if (price < previousPrice) {
            _priceColors[symbol] = Colors.red;
          }
        }

        // Temporarily set color to white before applying the actual color
        _priceColors[symbol] = Colors.white;
        Timer(Duration(seconds: 1), () {
          setState(() {
            if (price > prices.last.price) {
              _priceColors[symbol] = Colors.green;
            } else if (price < prices.last.price) {
              _priceColors[symbol] = Colors.red;
            }
          });
        });
      });
    });

    // Set up a timer to refresh the UI every 3 seconds
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        // Trigger a rebuild to refresh the chart data
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Top Cryptocurrencies'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: _cryptoSymbols.length,
          itemBuilder: (context, index) {
            final symbol = _cryptoSymbols[index];
            final prices = _cryptoPrices[symbol] ?? [];
            final priceColor = _priceColors[symbol] ?? Colors.white;

            return Card(
              color: Colors.grey[850],
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                contentPadding: EdgeInsets.all(16.0),
                leading: Icon(Icons.monetization_on, color: Colors.amber),
                title: Text(
                  symbol.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                trailing: SizedBox(
                  width: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 50,
                        width: 80,
                        child: SfCartesianChart(
                          plotAreaBorderColor: Colors.transparent, //remove Background
                          primaryXAxis: CategoryAxis(
                            isVisible: false,
                          ),
                          primaryYAxis: NumericAxis(
                            isVisible: false,
                            majorGridLines: MajorGridLines(width: 0),
                            labelFormat: '{value}',
                          ),
                          series: <ChartSeries>[
                            LineSeries<PriceData, String>(
                              dataSource: prices,
                              xValueMapper: (PriceData data, _) => data.time.toString(),
                              yValueMapper: (PriceData data, _) => data.price,
                              color: Colors.blue, // Adjust the line color as needed
                              width: 2,
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '\$${prices.isNotEmpty ? prices.last.price.toStringAsFixed(2) : '0.00'}',
                        style: TextStyle(color: priceColor, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PriceData {
  PriceData(this.time, this.price);

  final DateTime time;
  final double price;
}
