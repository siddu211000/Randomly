import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:randomly/router/app_routes.dart';

/// Phase 3: moderation, KYC flags, batch oversight. Stub for shared base.
class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operations',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Later: Digio KYC status, vendor verification, dispute tooling — '
              'all on the same Flutter codebase with role-gated routes.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Get.offAllNamed(AppRoutes.userHome),
              child: const Text('Back to traveller home'),
            ),
          ],
        ),
      ),
    );
  }
}
