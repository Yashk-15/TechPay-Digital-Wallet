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
          color: isLight ? AppTheme.bgSurface : AppTheme.bgInput,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppTheme.bgBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: AppTheme.coral,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.coral,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
