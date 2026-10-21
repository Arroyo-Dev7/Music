import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Encabezado de sala: sobretítulo en itálica, título en serif y una raya de oro.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.overline,
    required this.title,
    this.subtitle,
  });

  final String overline;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        MediaQuery.paddingOf(context).top + 22,
        22,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: AppColors.accent,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w600,
              fontSize: 42,
              height: 0.98,
              letterSpacing: -0.8,
              color: AppColors.cream,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 42,
            height: 1.5,
            color: AppColors.accent.withValues(alpha: 0.85),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: AppFonts.body,
                fontSize: 13.5,
                letterSpacing: 0.2,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
