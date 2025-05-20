// File: lib/widgets/reading_plans/reading_day_list_item.dart
// Path: lib/widgets/reading_plans/reading_day_list_item.dart
import 'package:flutter/material.dart';
import 'package:wwjd_app/models/models.dart'; // For ReadingPlanDay

class ReadingDayListItem extends StatelessWidget {
  final ReadingPlanDay day;
  final bool isCompleted;
  final bool isCurrentActiveDay;
  final VoidCallback onTap;
  // Pass ColorScheme and TextTheme if specific styling from context is needed,
  // or rely on Theme.of(context) within this widget.
  // For simplicity, let's assume Theme.of(context) can be used here for now.

  const ReadingDayListItem({
    super.key,
    required this.day,
    required this.isCompleted,
    required this.isCurrentActiveDay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme; // If needed for specific text styles

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCompleted
            ? Colors.green.shade100
            : (isCurrentActiveDay
                ? colorScheme.primaryContainer
                : colorScheme.surfaceVariant),
        child: isCompleted
            ? Icon(Icons.check_circle, color: Colors.green.shade700)
            : Text(
                day.dayNumber.toString(),
                style: TextStyle(
                  fontWeight:
                      isCurrentActiveDay ? FontWeight.bold : FontWeight.normal,
                  color: isCurrentActiveDay ? colorScheme.onPrimaryContainer : null,
                ),
              ),
      ),
      title: Text(
        day.title.isNotEmpty ? day.title : "Day ${day.dayNumber}",
        style: TextStyle(
            fontWeight:
                isCurrentActiveDay ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Text(day.passages.map((p) => p.displayText).join('; ')),
      trailing: isCurrentActiveDay && !isCompleted
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : (isCompleted
              ? null
              : Icon(Icons.circle_outlined,
                  size: 16, color: Colors.grey.shade400)),
      onTap: onTap,
      tileColor:
          isCurrentActiveDay ? colorScheme.primaryContainer.withOpacity(0.3) : null,
    );
  }
}