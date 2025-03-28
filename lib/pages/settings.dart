import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color.fromARGB(255, 246, 119, 162),
      ),
      body: Center(
        child: Text(
          "Set Settings",
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}