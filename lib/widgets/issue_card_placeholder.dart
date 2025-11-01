// lib/widgets/issue_card_placeholder.dart
import 'package:flutter/material.dart';

class IssueCardPlaceholder extends StatefulWidget {
  const IssueCardPlaceholder({super.key});
  @override
  State<IssueCardPlaceholder> createState() => _IssueCardPlaceholderState();
}
class _IssueCardPlaceholderState extends State<IssueCardPlaceholder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  Widget _buildPlaceholder(double width, double height, {double borderRadius = 8}) {
    return Container(width: width, height: height, decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: Colors.grey.shade300));
  }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            _buildPlaceholder(100, 100, borderRadius: 0),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPlaceholder(double.infinity, 20),
                    const SizedBox(height: 8),
                    _buildPlaceholder(150, 16),
                    const SizedBox(height: 8),
                    _buildPlaceholder(80, 24, borderRadius: 20),
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


