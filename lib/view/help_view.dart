import 'package:flutter/material.dart';
import 'package:listcom/extension/context_extension.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.help),
        elevation: 6,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Welcome to the Help page!\n\n'
          'If you need assistance, please contact our support team.\n\n'
          'Thank you for using our app!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
