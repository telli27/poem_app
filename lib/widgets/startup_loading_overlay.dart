import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/home/providers/poet_provider.dart';
import 'package:poemapp/features/home/providers/poem_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StartupLoadingOverlay extends ConsumerWidget {
  const StartupLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch both startup loading states, but with a try-catch
    bool isPoetLoading = false;
    bool isPoemLoading = false;

    try {
      isPoetLoading = ref.watch(poetStartupLoadingProvider);
    } catch (e) {
      print("❌ poetStartupLoadingProvider izlenirken hata: $e");
    }

    try {
      isPoemLoading = ref.watch(poemStartupLoadingProvider);
    } catch (e) {
      print("❌ poemStartupLoadingProvider izlenirken hata: $e");
    }

    // If neither is loading, don't show overlay
    if (!isPoetLoading && !isPoemLoading) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Animate(
            effects: const [
              FadeEffect(duration: Duration(milliseconds: 400)),
              ScaleEffect(
                begin: Offset(0.9, 0.9),
                end: Offset(1.0, 1.0),
                duration: Duration(milliseconds: 400),
                curve: Curves.easeOutQuart,
              ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 320,
                maxHeight: 280,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Custom spinner with animated gradient
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF1948A),
                            const Color(0xFFE57373),
                            const Color(0xFFEC7063),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE57373).withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(3.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE57373)),
                              strokeWidth: 2.5,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                        .rotate(
                          duration: 10.seconds,
                          curve: Curves.linear,
                        ),

                    const SizedBox(height: 28),

                    // Title text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Şiir icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE57373).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.library_books_outlined,
                            color: Color(0xFFE57373),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Şiirler kontrol ediliyor',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                      ],
                    ).animate(
                      delay: 300.ms,
                      effects: [
                        FadeEffect(duration: 500.ms),
                        SlideEffect(
                          begin: const Offset(0, 10),
                          end: const Offset(0, 0),
                          duration: 500.ms,
                          curve: Curves.easeOutCubic,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Animated dots with text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Veriler hazırlanıyor',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        _buildAnimatedDots(),
                      ],
                    ).animate(
                      delay: 500.ms,
                      effects: [
                        FadeEffect(duration: 500.ms),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Progress indicator
                    Container(
                      width: double.infinity,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFE57373),
                                  Color(0xFFF1948A),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          )
                              .animate(
                            onPlay: (controller) =>
                                controller.repeat(reverse: true),
                          )
                              .animate(
                            delay: 600.ms,
                            effects: [
                              ShimmerEffect(
                                duration: 2.seconds,
                                color: Colors.white30,
                                size: 1.0,
                                delay: 1.seconds,
                              ),
                              SlideEffect(
                                begin: const Offset(0, 0),
                                end: const Offset(2.4, 0),
                                duration: 3.seconds,
                                curve: Curves.easeInOut,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Animated dots for a more dynamic "loading" effect
  Widget _buildAnimatedDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAnimatedDot(100.ms),
        _buildAnimatedDot(200.ms),
        _buildAnimatedDot(300.ms),
      ],
    );
  }

  Widget _buildAnimatedDot(Duration delay) {
    return Container(
      width: 4,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFE57373),
        shape: BoxShape.circle,
      ),
    )
        .animate(
          onPlay: (controller) => controller.repeat(reverse: true),
        )
        .scaleY(
          begin: 1,
          end: 1.5,
          curve: Curves.easeInOut,
          duration: 0.6.seconds,
          delay: delay,
        );
  }
}
