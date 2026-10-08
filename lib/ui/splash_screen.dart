// Branded splash shown while the app store loads (SharedPreferences + first-run
// migration). Mirrors the native launch screen (dark background + logo) so the
// hand-off from the platform launch screen is seamless.
import 'package:flutter/material.dart';

import 'theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage('assets/brand/logo.png'),
                    width: 140,
                    height: 140,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text.rich(
                    TextSpan(
                      text: 'FIGHT ',
                      children: [
                        TextSpan(
                          text: 'CAMP',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                    style: TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
