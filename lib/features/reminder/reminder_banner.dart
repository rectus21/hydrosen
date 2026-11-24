import 'package:flutter/material.dart';

import '../thermos/thermos_theme.dart';
import 'character_avatar.dart';
import 'reminder_notifier.dart';

/// Uygulama içi temalı hatırlatma: karakterin resmi ve "susadım" cümlesi.
void showReminderBanner(
  BuildContext context,
  ReminderMessage message,
  ThermosTheme theme,
) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      key: const ValueKey('reminder-banner'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 10),
      backgroundColor: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: theme.edge, width: 2),
      ),
      content: Row(
        children: [
          CharacterAvatar(theme: theme, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message.body,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: const Color(0xFF0B1F3A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      showCloseIcon: true,
      closeIconColor: const Color(0xFF0B1F3A),
    ),
  );
}
