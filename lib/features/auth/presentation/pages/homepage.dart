import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Disables back button
      child: Scaffold(
        appBar: AppBar(title: const Text('HomePage'),automaticallyImplyLeading: false,),
        body: const Center(
          child: Text('HomePage'),
        ),
      ),
    );
  }
}
