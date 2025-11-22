import 'package:flutter/material.dart';

class CloudscansPage extends StatelessWidget {
  const CloudscansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Scans en la nube', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(child: Text("Cloud Scans")),
    );
  }
}
