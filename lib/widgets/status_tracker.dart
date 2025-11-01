// lib/widgets/status_tracker.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusTracker extends StatelessWidget {
  final int currentIndex;

  const StatusTracker({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    // Using .tr is common for GetX localization
    final List<String> statuses = [
      'created'.tr,
      'approved'.tr,
      'verified'.tr,
      'resolved'.tr
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(statuses.length, (index) {
        return _StatusStepNode(
          title: statuses[index],
          // A step is active if it is the current step or any step before it (completed).
          isActive: index <= currentIndex,
          // A step is completed if its index is strictly less than the current index.
          isCompleted: index < currentIndex,
          isLastStep: index == statuses.length - 1,
        );
      }),
    );
  }
}

/// A private widget representing a single node in the status tracker.
class _StatusStepNode extends StatelessWidget {
  final String title;
  final bool isActive;
  final bool isCompleted;
  final bool isLastStep;

  // Use a constant for the common animation duration
  static const animationDuration = Duration(milliseconds: 300);

  const _StatusStepNode({
    required this.title,
    required this.isActive,
    required this.isCompleted,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    // Use colorScheme for modern theme access
    final activeColor = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).dividerColor.withOpacity(0.7);
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Define the border color based on the status
    final borderColor = isActive ? activeColor : inactiveColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator Column: Dot and connecting line
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Animated Dot Wrapper
              AnimatedContainer(
                duration: animationDuration,
                // Scale the container border/size slightly when active
                width: 26, // Slightly larger base size
                height: 26,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2.5, // Slightly thicker border
                    color: borderColor,
                  ),
                  color: isCompleted
                      ? activeColor // Solid color when completed
                      : backgroundColor, // Background color when active/inactive
                ),
                child: Center(
                  // 1. Use AnimatedSwitcher for smooth icon transition
                  child: AnimatedSwitcher(
                    duration: animationDuration,
                    transitionBuilder: (child, animation) {
                      // Scale and Fade transition
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildIcon(context, activeColor),
                  ),
                ),
              ),
              // Animated Connecting Line
              if (!isLastStep)
                Expanded(
                  child: AnimatedContainer(
                    duration: animationDuration,
                    width: 3, // Slightly thicker line
                    // Line is active color only if the step is completed
                    color: isCompleted ? activeColor : inactiveColor,
                    margin: const EdgeInsets.symmetric(vertical: 4), // Small vertical margin
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Text Label
          Expanded(
            child: Padding(
              // Consistent padding for all items, makes the line look better
              padding: EdgeInsets.only(
                top: 4, // Aligns text with center of dot
                bottom: isLastStep ? 0 : 28.0, // Slightly reduced bottom padding
              ),
              child: AnimatedDefaultTextStyle(
                duration: animationDuration,
                curve: Curves.easeInOut, // Added a curve for a nicer feel
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  // More explicit color handling for contrast
                  color: isActive
                      ? Colors.black // Dark color for active text
                      : Colors.grey.shade600, // Subdued color for inactive text
                ),
                child: Text(title),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to build the icon inside the dot based on state.
  Widget _buildIcon(BuildContext context, Color activeColor) {
    // Assign a Key for AnimatedSwitcher to identify the change
    if (isCompleted) {
      return const Icon(
        Icons.check,
        key: ValueKey('completed'),
        size: 16,
        color: Colors.white,
      );
    } else if (isActive) {
      // Show a solid color inner dot for the current, non-completed step
      return const Center(
        child: SizedBox(
          key: ValueKey('active'),
          width: 8,
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
    // Return a simple container for inactive steps (Key is important)
    return const SizedBox(
      key: ValueKey('inactive'),
    );
  }
}