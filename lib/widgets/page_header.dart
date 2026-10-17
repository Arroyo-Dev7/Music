import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Encabezado editorial de cada pestaña: sobretítulo, título grande y subtítulo.
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
        20,
        MediaQuery.paddingOf(context).top + 24,
        20,
        18,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            overline.toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 36,
              height: 1.05,
              letterSpacing: -1,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
