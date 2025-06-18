import 'package:flutter/material.dart';

class NotifComponent extends StatefulWidget {
  @override
  _NotifcomponentState createState() => _NotifcomponentState();
}

class _NotifcomponentState extends State<NotifComponent> {
  bool isNotifEnabled = true;
  bool isVibrationEnabled = true;
  bool isRepeatEnabled = false;
  bool isReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationOption('Notifikasi', isNotifEnabled, (value) {
              setState(() {
                isNotifEnabled = value;
              });
            }),
            SizedBox(height: 30),
            _buildNotificationOption('Vibration', isVibrationEnabled, (value) {
              setState(() {
                isVibrationEnabled = value;
              });
            }),
            SizedBox(height: 30),
            _buildNotificationOption('Repeat', isRepeatEnabled, (value) {
              setState(() {
                isRepeatEnabled = value;
              });
            }),
            SizedBox(height: 30),
            _buildNotificationOption('Reminder', isReminderEnabled, (value) {
              setState(() {
                isReminderEnabled = value;
              });
            }),
            SizedBox(height: 30),
            _buildRingtoneOption('Ringtones', () {
              print('Open Ringtones');
            }),
          ],
        ),
      ),
    );
  }

  /// Widget untuk Switch Options
  Widget _buildNotificationOption(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.green,
          ),
        ],
      ),
    );
  }

  /// Widget untuk Ringtones Button
  Widget _buildRingtoneOption(String title, VoidCallback onPressed) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: Icon(Icons.folder, color: Colors.white),
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
