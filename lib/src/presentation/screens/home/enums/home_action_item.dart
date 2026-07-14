import 'package:flutter/material.dart';

class HomeActionItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const HomeActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });
}
