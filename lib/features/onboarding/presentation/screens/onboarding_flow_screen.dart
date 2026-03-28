import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/app/app_config.dart';
import '../../../../core/persistence/prefs_keys.dart';
import '../../../../core/persistence/prefs_service.dart';
import '../../../../core/ui_constants/app_spacing.dart';
import '../../../../data/auth/firebase_auth_repository.dart';
import '../../../../data/models/traveler_profile.dart';
import '../../../../data/repositories/traveler_profile_repository.dart';
import '../../../../router/app_routes.dart';

/// Collects traits + trip preferences for batch matching (Firestore `users/{uid}`).
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _page = PageController();
  final Set<String> _hobbies = {};
  final TextEditingController _personality = TextEditingController();

  DateTime? _tripStart;
  DateTime? _tripEnd;
  RangeValues _budget = const RangeValues(8000, 25000);
  double _maxDistanceKm = 400;
  RangeValues _ageComfort = const RangeValues(22, 38);
  String _gender = 'prefer_not_say';

  Future<void> _animateTo(int page) async {
    await _page.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  static const _hobbyOptions = <String>[
    'Travel',
    'Food',
    'Music',
    'Photography',
    'Hiking',
    'Nightlife',
    'Wellness',
    'Books',
    'Art',
    'Sports',
    'Tech',
    'Nature',
  ];

  @override
  void dispose() {
    _page.dispose();
    _personality.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _tripStart : _tripEnd;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _tripStart = picked;
      } else {
        _tripEnd = picked;
      }
    });
  }

  Future<void> _finish() async {
    final config = Get.find<AppConfig>();
    final prefs = Get.find<PrefsService>();

    if (!config.firebaseEnabled) {
      await prefs.setBool(PrefsKeys.onboardingCompleteLocal, true);
      if (!mounted) return;
      Get.offAllNamed(AppRoutes.userHome);
      return;
    }

    final auth = Get.find<FirebaseAuthRepository>();
    final repo = Get.find<TravelerProfileRepository>();
    final uid = auth.currentUser?.uid;
    if (uid == null) {
      await auth.ensureSignedIn();
    }
    final userId = auth.currentUser!.uid;
    final existing = await repo.fetchProfile(userId);

    final profile = TravelerProfile(
      uid: userId,
      hobbies: _hobbies.toList(),
      personalityNote: _personality.text.trim().isEmpty
          ? null
          : _personality.text.trim(),
      tripWindowStart: _tripStart,
      tripWindowEnd: _tripEnd,
      budgetMin: _budget.start,
      budgetMax: _budget.end,
      maxTravelDistanceKm: _maxDistanceKm,
      ageComfortMin: _ageComfort.start.round(),
      ageComfortMax: _ageComfort.end.round(),
      genderIdentity: _gender,
      onboardingComplete: true,
      matchingStatus: existing?.matchingStatus,
      batchId: existing?.batchId,
      queuedAt: existing?.queuedAt,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );

    await repo.saveProfile(profile);
    if (!mounted) return;
    Get.offAllNamed(AppRoutes.userHome);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your travel vibe'),
      ),
      body: PageView(
        controller: _page,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _welcomePage(scheme),
          _traitsPage(scheme),
          _prefsPage(scheme),
          _reviewPage(scheme),
        ],
      ),
    );
  }

  Widget _welcomePage(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New faces. Random place. Same energy as day one.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'We group travellers who vibe on personality scores, dates, budget, '
            'and distance — with a balanced mix. Vendors will take your batch on '
            'the trip once a destination is drawn.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _animateTo(1),
              child: const Text('Let’s build your profile'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _traitsPage(ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'What do you love?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'We use this to match you with similar personalities for the trip.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hobbyOptions.map((h) {
            final selected = _hobbies.contains(h);
            return FilterChip(
              label: Text(h),
              selected: selected,
              onSelected: (v) => setState(() {
                if (v) {
                  _hobbies.add(h);
                } else {
                  _hobbies.remove(h);
                }
              }),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Anything else about you?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _personality,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Hobbies, vibe, how you like to travel…',
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            TextButton(
              onPressed: () => _animateTo(0),
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _hobbies.isEmpty ? null : () => _animateTo(2),
              child: const Text('Continue'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _prefsPage(ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Trip window',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_tripStart == null
              ? 'Preferred start date'
              : 'Start: ${_tripStart!.toLocal().toString().split(' ').first}'),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDate(isStart: true),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_tripEnd == null
              ? 'Preferred end date'
              : 'End: ${_tripEnd!.toLocal().toString().split(' ').first}'),
          trailing: const Icon(Icons.calendar_today_outlined),
          onTap: () => _pickDate(isStart: false),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Comfortable budget (₹ approx range)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RangeSlider(
          values: _budget,
          min: 2000,
          max: 80000,
          divisions: 39,
          labels: RangeLabels(
            '${_budget.start.round()}',
            '${_budget.end.round()}',
          ),
          onChanged: (v) => setState(() => _budget = v),
        ),
        Text(
          'Max one-way distance you’re okay with',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: _maxDistanceKm,
          min: 100,
          max: 2500,
          divisions: 48,
          label: '${_maxDistanceKm.round()} km',
          onChanged: (v) => setState(() => _maxDistanceKm = v),
        ),
        Text(
          'Comfortable age range of co-travellers',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        RangeSlider(
          values: _ageComfort,
          min: 18,
          max: 70,
          divisions: 52,
          labels: RangeLabels(
            '${_ageComfort.start.round()}',
            '${_ageComfort.end.round()}',
          ),
          onChanged: (v) => setState(() => _ageComfort = v),
        ),
        const SizedBox(height: AppSpacing.md),
        Text('For balanced batches (optional)', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text('How you identify', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        DropdownButton<String>(
          isExpanded: true,
          value: _gender,
          items: const [
            DropdownMenuItem(value: 'prefer_not_say', child: Text('Prefer not to say')),
            DropdownMenuItem(value: 'woman', child: Text('Woman')),
            DropdownMenuItem(value: 'man', child: Text('Man')),
            DropdownMenuItem(value: 'non_binary', child: Text('Non-binary')),
          ],
          onChanged: (v) => setState(() => _gender = v ?? 'prefer_not_say'),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            TextButton(
              onPressed: () => _animateTo(1),
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => _animateTo(3),
              child: const Text('Review'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewPage(ColorScheme scheme) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text(
          'Looks good?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        _tile('Interests', _hobbies.join(', ')),
        _tile('Notes', _personality.text.isEmpty ? '—' : _personality.text),
        _tile(
          'Dates',
          '${_tripStart?.toLocal().toString().split(' ').first ?? '—'} → '
          '${_tripEnd?.toLocal().toString().split(' ').first ?? '—'}',
        ),
        _tile(
          'Budget',
          '₹${_budget.start.round()} – ₹${_budget.end.round()}',
        ),
        _tile('Max distance', '${_maxDistanceKm.round()} km'),
        _tile(
          'Age comfort',
          '${_ageComfort.start.round()} – ${_ageComfort.end.round()}',
        ),
        _tile('Gender (for ratio)', _gender),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            TextButton(
              onPressed: () => _animateTo(2),
              child: const Text('Back'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _finish,
              child: const Text('Start exploring'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _tile(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(body),
      ),
    );
  }
}
