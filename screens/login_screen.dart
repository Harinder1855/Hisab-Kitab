import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/sync_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final SyncService _syncService = SyncService();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(); // Bokeh animation ke liye
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. 🌈 PREMIUM GRADIENT BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF064e3b), // Deep Emerald
                  Color(0xFF022c22), // Darkest Green
                  Color(0xFF000000), // Black
                ],
              ),
            ),
          ),

          // 2. 🌌 ANIMATED BOKEH (Moving 3D Lights)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildAnimatedCircle(150, Colors.greenAccent.withOpacity(0.1), _controller.value),
                  _buildAnimatedCircle(250, Colors.yellowAccent.withOpacity(0.05), 1.0 - _controller.value),
                ],
              );
            },
          ),

          // 3. 🧪 GLASSMORPISM CENTER CARD
          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withOpacity(0.1), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        )
                      ],
                    ),
                    child: _isLoading 
                      ? const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: Color(0xFFfbbf24)), // Gold Loader
                            SizedBox(height: 20),
                            Text("Synchronizing Khata...", style: TextStyle(color: Colors.white70, letterSpacing: 1.5))
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 🎖️ 3D PREMIUM ICON
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFFfbbf24).withOpacity(0.2), blurRadius: 40, spreadRadius: 10)
                                ],
                              ),
                              child: const Icon(Icons.account_balance, size: 80, color: Color(0xFFfbbf24)), // Gold Icon
                            ),
                            const SizedBox(height: 30),
                            
                            // 🖋️ HISAB KITAB TITLE (Gradient Gold Style)
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFFfbbf24), Color(0xFFf59e0b), Colors.white],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ).createShader(bounds),
                              child: const Text(
                                "HISAB KITAB",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 40, 
                                  fontWeight: FontWeight.w900, 
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            const Text(
                              "PREMIUM DIGITAL LEDGER",
                              style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.bold),
                            ),
                            
                            const SizedBox(height: 60),

                            // 🔘 PREMIUM LOGIN BUTTON
                            InkWell(
                              onTap: () async {
                                setState(() => _isLoading = true);
                                final user = await _authService.signInWithGoogle();
                                if (user != null) {
                                  await _syncService.restoreData();
                                  databaseUpdateNotifier.value++;
                                }
                                if (mounted) setState(() => _isLoading = false);
                              },
                              child: Container(
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network('https://cdn-icons-png.flaticon.com/512/2991/2991148.png', height: 28),
                                    const SizedBox(width: 15),
                                    const Text(
                                      "Login with Google",
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF022c22)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user, color: Colors.white24, size: 14),
                                SizedBox(width: 5),
                                Text("End-to-End Encrypted Sync", style: TextStyle(color: Colors.white24, fontSize: 10)),
                              ],
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎇 ANIMATED BOKEH EFFECT WIDGET
  Widget _buildAnimatedCircle(double size, Color color, double animationValue) {
    return Positioned(
      top: 100 + (200 * animationValue),
      left: -50 + (300 * animationValue),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}