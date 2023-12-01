import './police_staton_database.dart';
import 'package:flutter/material.dart';


class DataPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact List'),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          String city = data.keys.elementAt(index);
          Map<String, String>? contacts = data[city];

          return ListTile(
            title: Text(city),
            onTap: () {
              _showContactsDialog(context, city, contacts!);
            },
          );
        },
      ),
    );
  }

  void _showContactsDialog(
      BuildContext context, String city, Map<String, String> contacts) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(city),
          content: SingleChildScrollView(
            child: Column(
              children: contacts.entries
                  .map(
                    (entry) => ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
