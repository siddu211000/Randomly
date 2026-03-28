import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:randomly/core/app/app_role.dart';
import 'package:randomly/core/common_widgets/app_card.dart';
import 'package:randomly/core/common_widgets/last_updated_refresh_chip.dart';
import 'package:randomly/core/common_widgets/refresh_icon_button.dart';
import 'package:randomly/core/common_widgets/value_notifier_builder.dart';
import 'package:randomly/data/auth/firebase_auth_repository.dart';
import 'package:randomly/data/models/traveler_profile.dart';
import 'package:randomly/data/repositories/traveler_profile_repository.dart';
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
  bool _joinBusy = false;

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

  String _matchingLabel(TravelerProfile? p) {
    if (p == null) return 'Sign in to continue.';
    final s = p.matchingStatus;
    if (s == 'queued') {
      return 'You are in the matching pool. The next scheduled job will try to '
          'place you in a group of six.';
    }
    if (s == 'in_batch' && (p.batchId ?? '').isNotEmpty) {
      return 'You have been assigned to a trip batch.';
    }
    return 'Not in the pool yet. Tap below when you are ready to be matched.';
  }

  Future<void> _joinPool(String uid, TravelerProfile? profile) async {
    if (_joinBusy || profile == null) return;
    if (!profile.onboardingComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finish onboarding first.'),
        ),
      );
      return;
    }
    if (profile.role != AppRole.user) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only travellers can join the matching pool.'),
        ),
      );
      return;
    }
    final status = profile.matchingStatus;
    if (status == 'queued' || status == 'in_batch') return;

    setState(() => _joinBusy = true);
    try {
      await Get.find<TravelerProfileRepository>().joinMatchingPool(uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are queued for matching.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not join pool: $e')),
      );
    } finally {
      if (mounted) setState(() => _joinBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<FirebaseAuthRepository>();
    final repo = Get.find<TravelerProfileRepository>();
    final uid = auth.currentUser?.uid;

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
          if (uid == null)
            AppCard(
              child: Text(
                'No signed-in user. Open the app from the splash flow.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            )
          else
            StreamBuilder<TravelerProfile?>(
              stream: repo.watchProfile(uid),
              builder: (context, snap) {
                final profile = snap.data;
                final batchId = profile?.batchId;
                final inBatch = profile?.matchingStatus == 'in_batch' &&
                    (batchId ?? '').isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                            _matchingLabel(profile),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                          if (inBatch) ...[
                            const SizedBox(height: 12),
                            StreamBuilder<Map<String, dynamic>?>(
                              stream: repo.watchBatchDoc(batchId!),
                              builder: (context, batchSnap) {
                                final b = batchSnap.data;
                                if (b == null) {
                                  return Text(
                                    'Loading batch…',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  );
                                }
                                final dest =
                                    b['destinationName'] as String? ?? '—';
                                final st =
                                    b['status'] as String? ?? 'unknown';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dest,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: $st',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Builder(
                            builder: (context) {
                              final status = profile?.matchingStatus;
                              final canJoin = profile != null &&
                                  profile.onboardingComplete &&
                                  profile.role == AppRole.user &&
                                  status != 'queued' &&
                                  status != 'in_batch';
                              String label;
                              if (status == 'queued') {
                                label = 'In matching pool';
                              } else if (status == 'in_batch') {
                                label = 'Matched — see above';
                              } else {
                                label = 'Join matching pool';
                              }
                              return SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: !canJoin || _joinBusy
                                      ? null
                                      : () => _joinPool(uid, profile),
                                  child: _joinBusy
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(label),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
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
