import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  // Add new optional color parameters
  final Color? backgroundColor;
  final Color? textColor;

  const InfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.backgroundColor, // Make it optional
    this.textColor,      // Make it optional
  });

  @override
  Widget build(BuildContext context) {
    // Use default colors if none are provided
    final defaultBg = Theme.of(context).cardColor;
    final defaultText = Theme.of(context).textTheme.bodyMedium?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Apply the provided background color or a default one
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          // Use the provided text color for a border hint, or a default grey
          color: (textColor ?? Colors.grey.shade300).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: textColor ?? defaultText,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: textColor ?? defaultText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}