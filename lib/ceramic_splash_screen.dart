import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:radhe/utils/constants.dart';
import 'package:radhe/utils/shared_pref.dart';

class CeramicSplashScreen extends StatefulWidget {
  const CeramicSplashScreen({super.key});

  @override
  State<CeramicSplashScreen> createState() => _CeramicSplashScreenState();
}

class _CeramicSplashScreenState extends State<CeramicSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _tileController;
  late AnimationController _logoController;
  late AnimationController _textController;

  late List<Animation<double>> _tileAnimations;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textOpacityAnimation;

  final int tilesPerRow = 6;
  final int tilesPerColumn = 10;
  late int totalTiles;
  String userID = '';

  @override
  void initState() {
    super.initState();

    totalTiles = tilesPerRow * tilesPerColumn;

    // Initialize animation controllers
    _tileController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered tile animations
    _tileAnimations = List.generate(totalTiles, (index) {
      final delay = (index * 0.05).clamp(0.0, 1.0);
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _tileController,
          curve: Interval(
            delay,
            (delay + 0.3).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic,
          ),
        ),
      );
    });

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    // Text animation
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    // Start tile animations
    _tileController.forward();

    // Start logo animation after tiles begin
    await Future.delayed(const Duration(milliseconds: 800));
    _logoController.forward();

    // Start text animation
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // Navigate to login after animations complete (wait ~4 seconds)
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      userID = await SharedPref.readString(userId) ?? '';
      AppConstants.userID = userID;
      AppConstants.LOGIN_USER_NAME =
          await SharedPref.readString(userName) ?? '';
      AppConstants.LOGIN_USER_EMAIL =
          await SharedPref.readString(userEmail) ?? '';
      AppConstants.LOGIN_USER_IS_ADMIN =
          await SharedPref.readString(isAdmin) ?? '';
      AppConstants.LOGIN_TOKEN = await SharedPref.readString(loginToken) ?? '';

      if (userID.isNotEmpty) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _tileController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final tileWidth = screenSize.width / tilesPerRow;
    final tileHeight = screenSize.height / tilesPerColumn;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: Stack(
        children: [
          // Ceramic tiles background
          ...List.generate(totalTiles, (index) {
            final row = index ~/ tilesPerRow;
            final col = index % tilesPerRow;

            return AnimatedBuilder(
              animation: _tileAnimations[index],
              builder: (context, child) {
                return Positioned(
                  left: col * tileWidth,
                  top: row * tileHeight,
                  width: tileWidth,
                  height: tileHeight,
                  child: Transform.scale(
                    scale: _tileAnimations[index].value,
                    child: Transform.rotate(
                      angle: (1 - _tileAnimations[index].value) * math.pi * 0.5,
                      child: Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _getTileColor(index).withOpacity(0.8),
                              _getTileColor(index).withOpacity(0.6),
                              _getTileColor(index).withOpacity(0.9),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Center logo and text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _logoScaleAnimation,
                    _logoOpacityAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(60),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/png/app_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // App name
                AnimatedBuilder(
                  animation: _textOpacityAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textOpacityAnimation.value,
                      child: const Text(
                        'Radhe',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTileColor(int index) {
    // Create a ceramic-like color palette
    final colors = [
      const Color(0xFF2D5AA0), // Deep blue
      const Color(0xFF1E3A8A), // Navy blue
      const Color(0xFF3B82F6), // Bright blue
      const Color(0xFF1D4ED8), // Medium blue
      const Color(0xFF2563EB), // Blue
      const Color(0xFF1E40AF), // Dark blue
    ];

    // Add some randomness while keeping it deterministic
    final colorIndex = (index + (index ~/ tilesPerRow)) % colors.length;
    return colors[colorIndex];
  }
}
