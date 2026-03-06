import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../app_router.dart';

class KYCVerificationScreen extends StatefulWidget {
  const KYCVerificationScreen({super.key});

  @override
  State<KYCVerificationScreen> createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  bool _idUploaded = false;
  bool _selfieUploaded = false;

  @override
  Widget build(BuildContext context) {
    final canContinue = _idUploaded && _selfieUploaded;

    return Scaffold(
      backgroundColor: AppTheme.bgAbyss,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.text100),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('KYC Verification',
            style: TextStyle(color: AppTheme.text100)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Progress ───────────────────────────────────────────────
              const Text(
                'Step 4 of 4 — Identity Verification',
                style: TextStyle(fontSize: 13, color: AppTheme.text400),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1.0,
                  minHeight: 6,
                  backgroundColor: AppTheme.bgElevated,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.coral),
                ),
              ),
              const SizedBox(height: 32),

              // ── Headline ───────────────────────────────────────────────
              const Text(
                'Verify your identity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text100,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Upload a government-issued ID and take a selfie to complete KYC.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.text400,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── Upload Items ───────────────────────────────────────────
              _UploadTile(
                icon: Icons.credit_card_rounded,
                label: 'Upload ID Document',
                sublabel: 'Aadhaar / PAN / Passport',
                uploaded: _idUploaded,
                onTap: () => setState(() => _idUploaded = !_idUploaded),
              ),
              const SizedBox(height: 16),
              _UploadTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take Selfie',
                sublabel: 'Face must be clearly visible',
                uploaded: _selfieUploaded,
                onTap: () => setState(() => _selfieUploaded = !_selfieUploaded),
              ),

              const Spacer(),

              // ── Trust badges ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.bgBorder),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        color: AppTheme.coral, size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your data is encrypted under AES-256 and will not be shared with third parties.',
                        style: TextStyle(fontSize: 12, color: AppTheme.text400),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── CTA Button ────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 56,
                decoration: canContinue
                    ? AppTheme.gradientButtonDecoration()
                    : BoxDecoration(
                        color: AppTheme.bgElevated,
                        borderRadius: BorderRadius.circular(16),
                      ),
                child: ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.postLoginWelcome,
                            (route) => false,
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    disabledBackgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    canContinue
                        ? 'Continue'
                        : 'Upload both documents to continue',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: canContinue ? Colors.white : AppTheme.text400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upload Tile ───────────────────────────────────────────────────────────────

class _UploadTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool uploaded;
  final VoidCallback onTap;

  const _UploadTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.uploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border.all(
            color: uploaded ? AppTheme.coral : AppTheme.bgBorder,
            width: uploaded ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: uploaded ? AppTheme.coralDim : AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                uploaded ? Icons.check_circle_rounded : icon,
                color: uploaded ? AppTheme.coral : AppTheme.text400,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: uploaded ? AppTheme.coral : AppTheme.text100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    uploaded ? 'Uploaded ✓' : sublabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: uploaded ? AppTheme.success : AppTheme.text400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              uploaded ? Icons.edit_outlined : Icons.arrow_forward_ios_rounded,
              color: AppTheme.text400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
