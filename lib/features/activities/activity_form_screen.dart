import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:run4share/app/app_icons.dart';
import 'package:run4share/app/clock.dart';
import 'package:run4share/app/material.dart';
import 'package:run4share/app/theme/app_spacing.dart';
import 'package:run4share/data/activity_repository.dart';
import 'package:run4share/data/database.dart';
import 'package:run4share/features/activities/activity_format.dart';
import 'package:run4share/features/settings/units.dart';
import 'package:run4share/features/strava/strava_models.dart';
import 'package:run4share/l10n/l10n.dart';
import 'package:run4share/shared/widgets/buttons.dart';
import 'package:run4share/shared/widgets/pills.dart';

/// Activity types offered for manual entry, as Strava sport types.
const manualSportTypes = ['Run', 'Ride', 'Hike', 'Walk', 'Workout'];

/// Seconds from "1:02:05", "33:14" or "45" (minutes); null if invalid.
int? parseDuration(String text) {
  final parts = text.trim().split(':');
  if (parts.isEmpty || parts.length > 3) return null;
  final numbers = parts.map(int.tryParse).toList();
  if (numbers.any((n) => n == null || n < 0)) return null;
  final n = numbers.cast<int>();
  final seconds = switch (n.length) {
    1 => n[0] * 60,
    2 => n[1] < 60 ? n[0] * 60 + n[1] : null,
    _ => n[1] < 60 && n[2] < 60 ? n[0] * 3600 + n[1] * 60 + n[2] : null,
  };
  return seconds == null || seconds == 0 ? null : seconds;
}

/// A positive number, accepting a decimal comma; null if empty or invalid.
double? parseNumber(String text) {
  final value = double.tryParse(text.trim().replaceAll(',', '.'));
  return value == null || value <= 0 ? null : value;
}

/// Add a manual activity, or edit one when [activityId] is given.
class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.activityId});

  final int? activityId;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<ActivityFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _duration = TextEditingController();
  final _distance = TextEditingController();
  final _calories = TextEditingController();
  final _heartRate = TextEditingController();
  final _shoe = TextEditingController();
  final _shoeDistance = TextEditingController();

  String _sportType = manualSportTypes.first;
  bool _race = false;
  late DateTime _start;
  bool _loading = false;
  bool _saving = false;

  bool get _editing => widget.activityId != null;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    // Wall-clock time stored as UTC, like Strava's start_date_local.
    _start = DateTime.utc(now.year, now.month, now.day, now.hour, now.minute);
    // A snack bar left over from the last screen would cover Save.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentSnackBar();
    });
    if (_editing) {
      _loading = true;
      unawaited(_load(widget.activityId!));
    }
  }

  Future<void> _load(int id) async {
    final activity = await ref.read(activityRepositoryProvider).byId(id);
    if (!mounted) return;
    if (activity == null || activity.source != ActivitySource.manual) {
      context.pop();
      return;
    }
    final format = _format();
    final number = NumberFormat('0.##', format.l10n.localeName);
    final gearId = activity.gearId;
    final gear = gearId == null
        ? null
        : await ref.read(activityRepositoryProvider).gearById(gearId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sportType = manualSportTypes.contains(activity.sportType)
          ? activity.sportType
          : manualSportTypes.first;
      _start = activity.startLocal;
      _race = activity.race;
      if (gear != null && gearId!.startsWith('manual:')) {
        _shoe.text = gear.name;
        if (gear.distance > 0) {
          _shoeDistance.text = NumberFormat(
            '0',
            format.l10n.localeName,
          ).format(gear.distance / format.metresPerUnit);
        }
      }
      _name.text = activity.name;
      _duration.text = format.duration(activity.movingTime);
      if (activity.distance case final metres?) {
        _distance.text = number.format(metres / format.metresPerUnit);
      }
      if (activity.calories case final kcal?) {
        _calories.text = kcal.round().toString();
      }
      if (activity.averageHeartrate case final bpm?) {
        _heartRate.text = bpm.round().toString();
      }
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _duration,
      _distance,
      _calories,
      _heartRate,
      _shoe,
      _shoeDistance,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ActivityFormat _format() => ActivityFormat(
        l10n: context.l10n,
        locale: Localizations.localeOf(context).toString(),
        units: ref.read(unitsProvider),
      );

  String _typeLabel(String sportType) {
    final l10n = context.l10n;
    return switch (sportType) {
      'Ride' => l10n.typeRide,
      'Hike' => l10n.typeHike,
      'Walk' => l10n.typeWalk,
      'Workout' => l10n.typeWorkout,
      _ => l10n.typeRun,
    };
  }

  /// The calendar only (no typing, no clock, Francisco 17 Nov 2026): the
  /// time of day stays as it was (now, for a new activity).
  Future<void> _pickStart() async {
    final now = ref.read(clockProvider)();
    final date = await showDatePicker(
      context: context,
      initialDate: _start.isAfter(now) ? now : _start,
      firstDate: DateTime(2000),
      lastDate: now,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (date == null || !mounted) return;
    setState(() {
      _start = DateTime.utc(
        date.year,
        date.month,
        date.day,
        _start.hour,
        _start.minute,
      );
    });
  }

  /// Hours, minutes and seconds on wheels, in a sheet.
  Future<void> _pickDuration() async {
    FocusScope.of(context).unfocus();
    final picked = await showDurationSheet(
      context,
      initial: Duration(seconds: parseDuration(_duration.text) ?? 0),
    );
    if (picked == null || !mounted) return;
    setState(() => _duration.text = _format().duration(picked.inSeconds));
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final format = _format();
    final name = _name.text.trim();
    final distance = parseNumber(_distance.text);
    setState(() => _saving = true);
    final repo = ref.read(activityRepositoryProvider);
    // A typed shoe is stored like Strava gear, keyed by its name, so the
    // shoe sticker works the same and the same name updates one shoe.
    final shoe = _shoe.text.trim();
    String? gearId;
    if (shoe.isNotEmpty) {
      gearId = 'manual:${shoe.toLowerCase()}';
      await repo.saveGear(
        StravaGear(
          id: gearId,
          name: shoe,
          distance:
              (parseNumber(_shoeDistance.text) ?? 0) * format.metresPerUnit,
        ),
      );
    }
    await ref.read(activityRepositoryProvider).saveManual(
          id: widget.activityId,
          name: name.isEmpty ? _typeLabel(_sportType) : name,
          sportType: _sportType,
          startLocal: _start,
          movingTime: parseDuration(_duration.text)!,
          distance: distance == null ? null : distance * format.metresPerUnit,
          calories: parseNumber(_calories.text),
          averageHeartrate: parseNumber(_heartRate.text),
          race: _race,
          gearId: gearId,
        );
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.activitySaved)));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final format = _format();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.back, size: 30),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => context.pop(),
        ),
        title: Text(_editing ? l10n.formTitleEdit : l10n.formTitleNew),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              top: false,
              child: Column(
                children: [
                  Expanded(
                    child: Form(
                      key: _form,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page + 4,
                          AppSpacing.sm,
                          AppSpacing.page + 4,
                          AppSpacing.xl,
                        ),
                        children: [
                          _Label(l10n.formType),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              for (final type in manualSportTypes)
                                AppPill(
                                  label: _typeLabel(type),
                                  icon: format.icon(sportKindOf(type)),
                                  variant: type == _sportType
                                      ? AppPillVariant.filled
                                      : AppPillVariant.outlined,
                                  onPressed: () =>
                                      setState(() => _sportType = type),
                                ),
                            ],
                          ),
                          _Label(l10n.formName),
                          TextFormField(
                            key: const ValueKey('activity.name'),
                            controller: _name,
                            textCapitalization: TextCapitalization.sentences,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: _typeLabel(_sportType),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Label(l10n.formDate),
                                    _DateField(
                                      text: format.day(_start),
                                      onTap: _pickStart,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Label(l10n.formDuration),
                                    // Tap-only: the wheels set it.
                                    TextFormField(
                                      key: const ValueKey('activity.duration'),
                                      controller: _duration,
                                      readOnly: true,
                                      showCursor: false,
                                      enableInteractiveSelection: false,
                                      onTap: _pickDuration,
                                      decoration: InputDecoration(
                                        hintText: l10n.formDurationHint,
                                        suffixIcon: const Icon(
                                          AppIcons.timer,
                                          size: 20,
                                        ),
                                      ),
                                      validator: (text) =>
                                          parseDuration(text ?? '') == null
                                              ? l10n.formDurationInvalid
                                              : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _OptionalNumber(
                                  label: l10n.formDistance(format.distanceUnit),
                                  controller: _distance,
                                  fieldKey: const ValueKey('activity.distance'),
                                  decimal: true,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: _OptionalNumber(
                                  label: l10n.formCalories,
                                  controller: _calories,
                                  fieldKey: const ValueKey('activity.calories'),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _OptionalNumber(
                                  label: l10n.formHeartRate,
                                  controller: _heartRate,
                                  fieldKey: const ValueKey('activity.bpm'),
                                  validator: (value) => value != null &&
                                          (value < 30 || value > 250)
                                      ? l10n.formHeartRateInvalid
                                      : null,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              const Expanded(child: SizedBox()),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Label(l10n.formShoe, optional: true),
                                    TextFormField(
                                      key: const ValueKey('activity.shoe'),
                                      controller: _shoe,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                flex: 2,
                                child: _OptionalNumber(
                                  label: l10n.formShoeDistance(
                                    format.distanceUnit,
                                  ),
                                  controller: _shoeDistance,
                                  fieldKey: const ValueKey('activity.shoeKm'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SwitchListTile(
                            value: _race,
                            onChanged: (value) => setState(() => _race = value),
                            title: Text(l10n.formRace),
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.formFootnote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: AppButton(
                      label: l10n.formSave,
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strong = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg + 2,
        bottom: AppSpacing.sm,
      ),
      child: Text.rich(
        TextSpan(
          text: text,
          style: strong,
          children: [
            if (optional)
              TextSpan(
                text: ' · ${context.l10n.formOptional}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(AppIcons.calendar, size: 20),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _OptionalNumber extends StatelessWidget {
  const _OptionalNumber({
    required this.label,
    required this.controller,
    required this.fieldKey,
    this.decimal = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final Key fieldKey;
  final bool decimal;

  /// Extra check on a parsed value; empty fields always pass.
  final String? Function(double? value)? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label, optional: true),
        TextFormField(
          key: fieldKey,
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: decimal),
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(decimal ? '[0-9.,]' : '[0-9]'),
            ),
          ],
          validator: (text) {
            if (text == null || text.trim().isEmpty) return null;
            final value = parseNumber(text);
            if (value == null) return l10n.formNumberInvalid;
            return validator?.call(value);
          },
        ),
      ],
    );
  }
}

/// A sheet with hour, minute and second wheels and Done; null if
/// dismissed. Returns at least one second.
Future<Duration?> showDurationSheet(
  BuildContext context, {
  required Duration initial,
}) {
  var value = initial;
  return showModalBottomSheet<Duration>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l10n = context.l10n;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.formDuration,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(
              height: 216,
              child: CupertinoTimerPicker(
                key: const ValueKey('activity.durationWheels'),
                initialTimerDuration: initial,
                onTimerDurationChanged: (d) => value = d,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.actionDone,
                  onPressed: () => Navigator.pop(
                    context,
                    value.inSeconds > 0 ? value : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
