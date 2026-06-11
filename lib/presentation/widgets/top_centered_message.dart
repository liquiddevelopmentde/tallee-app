import 'package:flutter/material.dart';

class TopCenteredMessage extends StatelessWidget {
  /// A widget that displays a message centered at the top of the screen with an icon, title, and message.
  /// - [icon]: The icon to display above the title.
  /// - [title]: The title text to display.
  /// - [message]: An optional message text to display below the title.
  /// - [content]: An optional widget to display below the title instead of the message text.
  /// - [fullscreen]: If true, the message will be displayed at the top of the
  const TopCenteredMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.fullscreen = true,
  });

  final IconData icon;

  final String title;

  final String? message;

  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: fullscreen ? const EdgeInsets.only(top: 100) : null,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: fullscreen
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Icon(icon, size: 45),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          if (message != null)
            Text(
              message!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
