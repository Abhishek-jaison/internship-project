import 'package:flutter/material.dart';

class DisplayWidget extends StatelessWidget {
  final List<dynamic> data;

  DisplayWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Data'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return ListTile(
            title: Text('Name: ${item['name']}'),
            subtitle: Text(
              'Encrypted Password: ${item['password']}\nVideo Details: ${item['videoDetails']}\nVideo Hash: ${item['videoDetails']['hash']}',
            ),
          );
        },
      ),
    );
  }
}
