import 'package:flutter/material.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  _DataPageState createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
        appBar: AppBar(
        title: const Text('Title'),
      ),
      body: Container(),
    ));
  }
}
