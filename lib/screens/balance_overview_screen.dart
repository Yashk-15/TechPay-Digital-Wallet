import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class BalanceOverviewScreen extends StatefulWidget {
  const BalanceOverviewScreen({super.key});

  @override
  State<BalanceOverviewScreen> createState() => _BalanceOverviewScreenState();
}

class _BalanceOverviewScreenState extends State<BalanceOverviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              24, 12, 24, 100), // Bottom padding for nav bar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Balance',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track spending, earnings, and insights',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textLight.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.more_vert, color: AppTheme.textDark),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Main Circular Chart
              Center(
                child: SizedBox(
                  height: 360,
                  width: 360,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background Circle with Dashed Border (Simulated)
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryDarkGreen.withOpacity(0.05),
                              blurRadius: 40,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),

                      // Progress Arc/Dash simulation
                      CustomPaint(
                        size: const Size(320, 320),
                        painter: DashedCirclePainter(),
                      ),

                      // Wave Chart Inside
                      ClipOval(
                        child: Container(
                          width: 280,
                          height: 280,
                          color: Colors.transparent, // Background of chart
                          child: Stack(
                            children: [
                              // The Wave
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    return CustomPaint(
                                      painter: WavePainter(
                                        color: AppTheme.accentLime,
                                        animationValue: _controller.value,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              // Content Overlay
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryDarkGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.currency_rupee,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    // +27% Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryDarkGreen,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        '+27%',
                                        style: TextStyle(
                                          color: AppTheme.accentLime,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      '₹4,30,957.02',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Total Balance',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Floating Buttons on the Curve
                      Positioned(
                        bottom: 40,
                        left: 60,
                        child:
                            _buildChartButton(Icons.candlestick_chart, false),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 110,
                        child: _buildChartButton(Icons.pie_chart, false),
                      ),
                      Positioned(
                        bottom: 10,
                        child:
                            _buildChartButton(Icons.show_chart, true), // Active
                      ),
                      Positioned(
                        bottom: 20,
                        right: 110,
                        child: _buildChartButton(Icons.percent, false),
                      ),
                      Positioned(
                        bottom: 40,
                        right: 60,
                        child: _buildChartButton(
                            Icons.account_balance_wallet, false),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Income Statistics Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDarkGreen,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDarkGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentLime.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.attach_money,
                                color: AppTheme.accentLime,
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Income',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'February',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accentLime,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '+27%',
                                style: TextStyle(
                                  color: AppTheme.primaryDarkGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'vs last month',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const Text(
                          '₹2,31,039.00',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Mini Graph (Simulated using Row of Columns)
                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(20, (index) {
                          final height =
                              10 + (math.Random().nextInt(40)).toDouble();
                          final isSelected = index == 15;
                          return Container(
                            width: 6,
                            height: height,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.accentLime
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Extra: Breakdown options (Investment, Salaries, etc from image bottom)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomLabel('Salary'),
                  _buildBottomLabel('Investment'),
                  _buildBottomLabel('Side Profit'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartButton(IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () {
        // Functionality for button tap
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Switched to ${icon.toString()} view')),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryDarkGreen : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? AppTheme.accentLime : AppTheme.textLight,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBottomLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppTheme.textLight.withOpacity(0.6),
        fontSize: 12,
      ),
    );
  }
}

// Custom Painter for the Wave
class WavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  WavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;

    // Wave parameters
    final midY = height * 0.6;
    const amplitude = 20.0;

    path.moveTo(0, midY);

    for (double x = 0; x <= width; x++) {
      // Create a moving wave effect
      final y = midY +
          math.sin((x / width * 4 * math.pi) + (animationValue * 2 * math.pi)) *
              amplitude;
      path.lineTo(x, y);
    }

    // Fill to bottom
    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    // Draw Fill
    canvas.drawPath(path, paint);

    // Draw Stroke (Line)
    final pathLine = Path();
    pathLine.moveTo(
        0, midY + math.sin((animationValue * 2 * math.pi)) * amplitude);
    for (double x = 0; x <= width; x++) {
      final y = midY +
          math.sin((x / width * 4 * math.pi) + (animationValue * 2 * math.pi)) *
              amplitude;
      pathLine.lineTo(x, y);
    }

    // Gradient for the line
    final shader = const LinearGradient(
      colors: [AppTheme.primaryDarkGreen, AppTheme.accentLime],
    ).createShader(Rect.fromLTWH(0, 0, width, height));

    linePaint.shader = shader;

    canvas.drawPath(pathLine, linePaint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

// Dashed Circle Painter
class DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textLight.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 5.0;
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    double startAngle = 0;
    while (startAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidth / radius, // approximate angle for dash width
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
