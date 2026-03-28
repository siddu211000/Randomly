import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:randomly/router/app_routes.dart';

/// Phase 2: trip operator accepts / declines batches. Stub for shared app shell.
class VendorHomeScreen extends StatelessWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vendor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Batch inbox',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              'When a traveller batch is formed and a random destination is '
              'drawn, vendors will see it here and accept or pass. Same core '
              'app, different role entry.',
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
