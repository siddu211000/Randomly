import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:randomly/core/common_widgets/app_card.dart';
import 'package:randomly/core/common_widgets/last_updated_refresh_chip.dart';
import 'package:randomly/core/common_widgets/refresh_icon_button.dart';
import 'package:randomly/core/common_widgets/value_notifier_builder.dart';
import 'package:randomly/router/app_routes.dart';

/// Primary home for the **traveller** experience (phase 1).
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  DateTime? _lastRefresh;
  bool _refreshBusy = false;

  @override
  void initState() {
    super.initState();
    _lastRefresh = DateTime.now();
  }

  @override
  void dispose() {
    _counter.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_refreshBusy) return;
    setState(() => _refreshBusy = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() {
      _lastRefresh = DateTime.now();
      _refreshBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover trips'),
        actions: [
          RefreshIconButton(
            isRefreshing: _refreshBusy,
            onPressed: _onRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const SizedBox(height: 8),
          LastUpdatedRefreshChip(
            lastUpdated: _lastRefresh,
            onRefresh: _onRefresh,
          ),
          const SizedBox(height: 8),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your batch',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Matching, random destination draw, and vendor handoff will '
                  'plug in here. Firebase stores your onboarding profile today; '
                  'a proper backend can take over later.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          AppCard(
            child: ValueNotifierBuilder<int>(
              notifier: _counter,
              builder: (context, value, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Engagement demo',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$value',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                );
              },
            ),
          ),
          AppCard(
            onTap: () => Get.toNamed(AppRoutes.vendorHome),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Vendor portal'),
              subtitle: Text(
                'Preview — accept trip batches (phase 2)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          AppCard(
            onTap: () => Get.toNamed(AppRoutes.adminHome),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Admin'),
              subtitle: Text(
                'Preview — operations (phase 3)',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () => Get.toNamed(AppRoutes.authentication),
              child: const Text('Account / sign-in (later)'),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _counter.value++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
