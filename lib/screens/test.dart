import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Height Bottom Sheet'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled:
                  true, // Set to true to enable content scrolling
              builder: (context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 50, width: 100, decoration: BoxDecoration(color: Colors.red),),
                      SizedBox(height: 16.0),
                      Container(height: 80, width: 100, decoration: BoxDecoration(color: Colors.green),),
                      Container(height: 80, width: 100, decoration: BoxDecoration(color: Colors.green),)
                      // Add more widgets as needed
                    ],
                  ),
                );
              },
            );
          },
          child: Text('Show Bottom Sheet'),
        ),
      ),
    );
  }
}
