import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';

class TradingSimulator extends StatefulWidget {
  @override
  _TradingSimulatorState createState() => _TradingSimulatorState();
}

class _TradingSimulatorState extends State<TradingSimulator> {
  late WebSocketService _webSocketService;
  List<Candle> _candles = [];
  double _currentPrice = 0;
  double _usdtBalance = 100.0; // Initial USDT balance
  double _btcBalance = 0.0; // Initial BTC balance
  bool _isTrading = false;
  double? _startPrice;
  List<Candle> _currentPriceList =
      []; // List to track the current price for the line series
  double _amount = 0; // Variable to store the amount entered by the user

  @override
  void initState() {
    super.initState();
    _webSocketService =
        WebSocketService('wss://stream.binance.com:9443/ws/btcusdt@kline_1m');
    _webSocketService.stream.listen((message) {
      final decodedMessage = json.decode(message);
      final candle = Candle.fromJson(decodedMessage['k']);
      setState(() {
        _currentPrice = candle.close;
        _updateCandles(candle);
        _updateCurrentPriceList(candle);
      });
    });
  }

  void _updateCandles(Candle newCandle) {
    final now = DateTime.now();
    if (_candles.isEmpty ||
        _candles.last.timestamp.isBefore(now.subtract(Duration(minutes: 1)))) {
      setState(() {
        _candles.add(newCandle);
        if (_candles.length > 60) {
          _candles.removeAt(0); // Keep latest 60 candles
        }
      });
    }
  }

  void _updateCurrentPriceList(Candle newCandle) {
    if (_currentPriceList.isEmpty ||
        _currentPriceList.last.timestamp
            .isBefore(DateTime.now().subtract(Duration(minutes: 1)))) {
      setState(() {
        _currentPriceList.add(newCandle);
        if (_currentPriceList.length > 60) {
          _currentPriceList.removeAt(0); // Keep latest 60 points
        }
      });
    }
  }

  void _startTrade(bool isBuy) {
    if (_isTrading) return;

    // Calculate maximum amounts
    double maxBuyAmount = _usdtBalance / _currentPrice;
    double maxSellAmount = _btcBalance;

    // Show dialog to get amount
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(
          'Enter Amount',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _amount = double.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 10),
            Text(
              'Max ${isBuy ? 'Buy' : 'Sell'} Amount: ${isBuy ? maxBuyAmount.toStringAsFixed(4) : maxSellAmount.toStringAsFixed(4)} BTC',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              'Submit',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _executeTrade(isBuy);
            },
          ),
        ],
      ),
    );
  }

  void _executeTrade(bool isBuy) {
    if (_isTrading) return;

    setState(() {
      _isTrading = true;
      _startPrice = _currentPrice;

      // Debug values
      print('Amount to Trade: $_amount');
      print('Current Price: $_currentPrice');

      // Check for calculations
      double requiredUSDT = _amount * _currentPrice;

      print('Required USDT for Trade: $requiredUSDT');

      if (isBuy) {
        if (_usdtBalance >= requiredUSDT) {
          _btcBalance += _amount;
          _usdtBalance -= requiredUSDT;
          print('Buy successful!');
          print('New BTC Balance: $_btcBalance');
          print('New USDT Balance: $_usdtBalance');
        } else {
          print('Insufficient USDT balance!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient USDT balance!')),
          );
        }
      } else {
        if (_btcBalance >= _amount) {
          _usdtBalance += _amount * _currentPrice;
          _btcBalance -= _amount;
          print('Sell successful!');
          print('New BTC Balance: $_btcBalance');
          print('New USDT Balance: $_usdtBalance');
        } else {
          print('Insufficient BTC balance!');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Insufficient BTC balance!')),
          );
        }
      }

      _isTrading = false;
    });
  }

  @override
  void dispose() {
    _webSocketService.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BTC/USD Trading App'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Card(
            color: Colors.black,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'BTC/USD Price:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 400,
                      child: SfCartesianChart(
                        backgroundColor: Colors.black,
                        primaryXAxis: DateTimeAxis(
                          intervalType: DateTimeIntervalType.minutes,
                          dateFormat: DateFormat('HH:mm'),
                          majorGridLines: MajorGridLines(width: 0),
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        primaryYAxis: NumericAxis(
                          labelFormat: '{value}',
                          majorGridLines: MajorGridLines(width: 0),
                          axisLine: AxisLine(width: 0),
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        series: <ChartSeries<Candle, DateTime>>[
                          CandleSeries<Candle, DateTime>(
                            dataSource: _candles,
                            xValueMapper: (Candle candle, _) =>
                                candle.timestamp,
                            highValueMapper: (Candle candle, _) => candle.high,
                            lowValueMapper: (Candle candle, _) => candle.low,
                            openValueMapper: (Candle candle, _) => candle.open,
                            closeValueMapper: (Candle candle, _) =>
                                candle.close,
                            bullColor: Colors.green,
                            bearColor: Colors.red,
                            borderWidth: 2,
                            enableTooltip: true,
                            name: 'BTC/USD',
                            dataLabelSettings: DataLabelSettings(
                                isVisible: false), // Hide data labels
                          ),
                          LineSeries<Candle, DateTime>(
                            dataSource: _currentPriceList,
                            xValueMapper: (Candle candle, _) =>
                                candle.timestamp,
                            yValueMapper: (Candle candle, _) => candle.close,
                            color: Colors.blue,
                            width: 2,
                            name: 'Current Price',
                            markerSettings: MarkerSettings(
                              isVisible: true,
                              color: Colors.blue,
                              borderColor: Colors.blue,
                              borderWidth: 2,
                            ),
                          ),
                        ],
                        tooltipBehavior: TooltipBehavior(
                          enable: true,
                          header: '',
                          canShowMarker: true,
                          textStyle: TextStyle(color: Colors.white),
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _startTrade(true),
                          child: Text(
                            'Buy BTC',
                            style: TextStyle(
                                color: Colors.white), // Set text color to white
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green, // Background color
                            foregroundColor: Colors.white, // Text color
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () => _startTrade(false),
                          child: Text(
                            'Sell BTC',
                            style: TextStyle(
                                color: Colors.white), // Set text color to white
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Background color
                            foregroundColor: Colors.white, // Text color
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Current Price: $_currentPrice USD',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'USDT Balance: $_usdtBalance USD',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'BTC Balance: $_btcBalance BTC',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Candle {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['t']),
      open: double.parse(json['o']),
      high: double.parse(json['h']),
      low: double.parse(json['l']),
      close: double.parse(json['c']),
    );
  }

  @override
  String toString() {
    return 'Candle{timestamp: $timestamp, open: $open, high: $high, low: $low, close: $close}';
  }
}

class WebSocketService {
  final String url;
  late final StreamController<String> _controller;
  late final WebSocketChannel _webSocketChannel;

  WebSocketService(this.url) {
    _controller = StreamController<String>();
    _initWebSocket();
  }

  Stream<String> get stream => _controller.stream;

  void _initWebSocket() {
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(url));
    _webSocketChannel.stream.listen((data) {
      _controller.add(data);
    }, onError: (error) {
      _controller.addError(error);
    }, onDone: () {
      _controller.close();
    });
  }

  void closeConnection() {
    _webSocketChannel.sink.close();
  }
}
