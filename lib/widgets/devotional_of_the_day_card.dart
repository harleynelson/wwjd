// lib/widgets/devotional_of_the_day_card.dart
import 'package:flutter/material.dart';

import '../daily_devotions.dart';

class DevotionalOfTheDayCard extends StatefulWidget {
  final Devotional devotional;
  final bool isLoading;

  const DevotionalOfTheDayCard({
    super.key,
    required this.devotional,
    this.isLoading = false,
  });

  @override
  State<DevotionalOfTheDayCard> createState() => _DevotionalOfTheDayCardState();
}

class _DevotionalOfTheDayCardState extends State<DevotionalOfTheDayCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.isLoading) {
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (widget.devotional.title == "No Devotional Available" || widget.devotional.title == "Content Coming Soon") {
      // ... (placeholder handling remains the same)
      return Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Daily Reflection", // Generic title
                style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 12.0),
              Text(
                widget.devotional.coreMessage,
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                widget.devotional.reflection,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Reflection: ${widget.devotional.title}",
              style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              widget.devotional.coreMessage,
              style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: colorScheme.secondary,
                  ),
              maxLines: _isExpanded ? null : 3,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // Explicitly visible when expanded
            ),
            const SizedBox(height: 10.0),
            if (widget.devotional.scriptureFocus.isNotEmpty) ...[
              RichText(
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(height: 1.5),
                  children: [
                    TextSpan(
                      text: '"${widget.devotional.scriptureFocus}" ',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    TextSpan(
                      text: widget.devotional.scriptureReference,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary.withOpacity(0.8)),
                    ),
                  ],
                ),
                maxLines: _isExpanded ? null : 2,
                overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis, // Explicitly visible when expanded
              ),
              const SizedBox(height: 10.0),
            ],

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: colorScheme.primary.withOpacity(0.2)),
                  const SizedBox(height: 12.0),
                  SelectableText(
                    widget.devotional.reflection,
                    style: textTheme.bodyMedium?.copyWith(height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16.0),
                  Divider(color: colorScheme.primary.withOpacity(0.2)),
                  const SizedBox(height: 12.0),
                  Text(
                    "Today's Declaration:",
                    style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                  SelectableText(
                    widget.devotional.prayerDeclaration,
                    style: textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: colorScheme.tertiary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _isExpanded ? "Show Less" : "Read More",
                      style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: colorScheme.primary,
                      size: 20.0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}