// File: lib/widgets/reading_plans/horizontal_reading_plan_section.dart
// Path: lib/widgets/reading_plans/horizontal_reading_plan_section.dart
// Corrected: Removed const from constructor and made fields final.
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/models.dart';
import 'package:wwjd_app/theme/app_colors.dart';
import 'package:wwjd_app/widgets/reading_plans/reading_plan_list_item.dart';

class HorizontalReadingPlanSection extends StatelessWidget {
  final String sectionTitle;
  final List<ReadingPlan> plans;
  final Map<String, UserReadingProgress?> progressMap;
  final bool devPremiumEnabled;
  final Function(ReadingPlan, List<Color>, Alignment, Alignment) onPlanTap;
  final int gradientIndexOffset;

  // Made these final and initialized them directly.
  // For a StatelessWidget, these could also be static const if they never change.
  final List<Alignment> _gradientAlignmentsBegin = const [
    Alignment.topLeft, Alignment.topCenter, Alignment.topRight, Alignment.centerLeft,
    Alignment.bottomLeft, Alignment.center,
  ];
  final List<Alignment> _gradientAlignmentsEnd = const [
    Alignment.bottomRight, Alignment.bottomCenter, Alignment.bottomLeft, Alignment.centerRight,
    Alignment.topRight, Alignment.center,
  ];

  // Removed 'const' from the constructor
  HorizontalReadingPlanSection({
    super.key,
    required this.sectionTitle,
    required this.plans,
    required this.progressMap,
    required this.devPremiumEnabled,
    required this.onPlanTap,
    this.gradientIndexOffset = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const SizedBox.shrink();
    }

    const double itemHeight = 240.0;
    const double itemWidth = 280.0;
    final Random random = Random(); // Moved Random instantiation here if needed per build, or make static if appropriate

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
          child: Text(
            sectionTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: itemHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            itemCount: plans.length,
            itemBuilder: (context, index) {
              final plan = plans[index];
              // Use AppColors.getReadingPlanGradient for consistency if it has similar logic,
              // otherwise, the local _gradientAlignmentsBegin/End logic is fine.
              final List<Color> gradient = AppColors.getReadingPlanGradient(index + gradientIndexOffset); //
              final Alignment beginAlignment = _gradientAlignmentsBegin[(index + gradientIndexOffset) % _gradientAlignmentsBegin.length];
              final Alignment endAlignment = _gradientAlignmentsEnd[(index + gradientIndexOffset) % _gradientAlignmentsEnd.length];
              final bool isPlanEffectivelyLocked = plan.isPremium && !devPremiumEnabled;

              return Container(
                width: itemWidth,
                margin: const EdgeInsets.only(right: 12.0),
                child: ReadingPlanListItem( //
                  plan: plan,
                  progress: progressMap[plan.id],
                  onTap: () => onPlanTap(plan, gradient, beginAlignment, endAlignment),
                  backgroundGradientColors: gradient,
                  beginGradientAlignment: beginAlignment,
                  endGradientAlignment: endAlignment,
                  isPlanEffectivelyLocked: isPlanEffectivelyLocked,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}