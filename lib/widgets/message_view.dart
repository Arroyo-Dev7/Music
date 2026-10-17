import 'package:flutter/material.dart';

import 'empty_state.dart';

/// Mensaje a pantalla completa con botón (permisos, errores, vacío...).
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.text,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String text;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: text,
      actionLabel: buttonLabel,
      onAction: onPressed,
    );
  }
}
