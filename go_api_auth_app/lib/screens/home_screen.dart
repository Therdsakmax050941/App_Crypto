import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cryptocurrency News'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildNewsItem(
              'Bitcoin Hits New All-Time High!',
              'Bitcoin has reached a new all-time high price of \$60,000. Experts predict further growth in the coming months.',
              'assets/images/bitcoin.jpg', // Add your image asset here
            ),
            SizedBox(height: 20),
            _buildNewsItem(
              'Ethereum 2.0 Upgrade Coming Soon',
              'Ethereum is set to launch its 2.0 upgrade, promising faster transactions and lower fees. This upgrade will transform the Ethereum network.',
              'assets/images/ethereum.png', // Add your image asset here
            ),
            SizedBox(height: 20),
            _buildNewsItem(
              'Ripple Faces Legal Battle with SEC',
              'Ripple Labs is facing a legal battle with the SEC over the legality of its cryptocurrency, XRP. The outcome could impact the entire crypto market.',
              'assets/images/ripple.png', // Add your image asset here
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(String title, String description, String imagePath) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
