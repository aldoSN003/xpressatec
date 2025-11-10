import 'package:flutter/material.dart';

class DrawerActionCard extends StatelessWidget {
  const DrawerActionCard({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.gradientColors,
  });

  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<Color> colors = gradientColors ??
        const [
          Color(0xFF40C4FF),
          Color(0xFFE1F5FE),
        ];

    final Color foregroundColor = Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          constraints: const BoxConstraints(minHeight: 72),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: const Color(0xFF2962FF),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: foregroundColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: foregroundColor.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: foregroundColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
