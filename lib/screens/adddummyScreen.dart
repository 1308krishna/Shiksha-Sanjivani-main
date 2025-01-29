import 'package:classinsight/screens/adddummy.dart';
import 'package:flutter/material.dart';

class AddSchoolScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Dummy School')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            DatabaseService().fetc();
          },
          child: Text('Add Dummy School'),
        ),
      ),
    );
  }
}

