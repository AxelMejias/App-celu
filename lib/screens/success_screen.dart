import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, size: 100, color: Colors.green),
                const SizedBox(height: 24),
                const Text(
                  '¡Correcto!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Alarma desactivada.\nVolviendo al inicio...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
