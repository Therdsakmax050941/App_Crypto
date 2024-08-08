import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.black,
      ),
      body: SettingsList(),
    );
  }
}

class SettingsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.0),
      children: [
        // Account Settings
        ListTile(
          leading: Icon(Icons.account_circle, color: Colors.blue),
          title: Text('Account'),
          subtitle: Text('Manage your account settings'),
          onTap: () {
            // Navigate to account settings page or show dialog
          },
        ),
        Divider(),

        // Theme Settings
        ListTile(
          leading: Icon(Icons.palette, color: Colors.green),
          title: Text('Theme'),
          subtitle: Text('Select app theme'),
          onTap: () {
            // Show theme selection dialog or navigate to theme settings page
          },
        ),
        Divider(),

        // Notification Settings
        ListTile(
          leading: Icon(Icons.notifications, color: Colors.orange),
          title: Text('Notifications'),
          subtitle: Text('Manage your notifications'),
          onTap: () {
            // Navigate to notification settings page
          },
        ),
        Divider(),

        // About
        ListTile(
          leading: Icon(Icons.info, color: Colors.teal),
          title: Text('About'),
          subtitle: Text('App information and credits'),
          onTap: () {
            // Show about dialog or navigate to about page
          },
        ),
        Divider(),

        // Logout
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text('Logout'),
          subtitle: Text('Sign out of your account'),
          onTap: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('jwt'); // Remove JWT token
            Navigator.pushReplacementNamed(context, '/login'); // Navigate to login screen
          },
        ),
      ],
    );
  }
}
