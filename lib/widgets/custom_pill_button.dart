import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomPillButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isLight;
  final VoidCallback onTap;

  const CustomPillButton({
    super.key,
    required this.text,
    required this.icon,
    this.isLight = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border:
              isLight ? null : Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isLight ? AppTheme.primaryDarkGreen : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isLight ? AppTheme.primaryDarkGreen : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
