// File: lib/widgets/home/home_navigation_button.dart
// Path: lib/widgets/home/home_navigation_button.dart
import 'package:flutter/material.dart';

class HomeNavigationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const HomeNavigationButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        leading: Icon(icon, size: 28, color: theme.colorScheme.primary),
        title: Text(label,
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.arrow_forward_ios,
            size: 16, color: theme.colorScheme.onSurfaceVariant),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
    );
  }
}