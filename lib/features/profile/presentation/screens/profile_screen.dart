import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:randomly/features/profile/presentation/helper/profile_strings.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ProfileStrings.title),
      ),
      body: Center(
        child: FilledButton(
          onPressed: Get.back<void>,
          child: const Text('Go back'),
        ),
      ),
    );
  }
}
