import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:randomly/router/app_routes.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
      ),
      body: Center(
        child: FilledButton(
          onPressed: () => Get.offAllNamed(AppRoutes.userHome),
          child: const Text('Back to home'),
        ),
      ),
    );
  }
}
