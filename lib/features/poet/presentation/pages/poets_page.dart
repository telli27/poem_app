import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poemapp/features/poet/domain/entities/poet.dart' as entity;
import 'package:poemapp/models/poet.dart' as model;
import 'package:poemapp/features/poet/presentation/providers/poet_provider.dart';
import 'package:poemapp/features/poet/presentation/pages/poet_detail_page.dart';
import 'package:flutter_animate/flutter_animate.dart';

// Convert from entity.Poet to model.Poet
model.Poet _convertToModelPoet(entity.Poet poet) {
  return model.Poet(
    id: poet.id,
    name: poet.name,
    birthDate: poet.birthYear?.toString() ?? '',
    deathDate: poet.deathYear?.toString() ?? '',
    biography: poet.biography ?? '',
    imageUrl: poet.imageUrl ?? '',
    periods: [],
    styles: [],
    notableWorks: [],
    birthPlace: '',
    deathPlace: '',
    influences: [],
    influencedBy: [],
  );
}

class PoetsPage extends ConsumerWidget {
  const PoetsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final poetsAsync = ref.watch(poetsProvider);
    final bgColor = const Color(0xFFF5F7FA);
    final accentColor = Colors.indigo.shade700;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // App Bar
            SliverToBoxAdapter(
              child: Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 600)),
                ],
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(4, 4),
                                    blurRadius: 8,
                                  ),
                                  const BoxShadow(
                                    color: Colors.white,
                                    offset: Offset(-4, -4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Şairler',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Search Box
            SliverToBoxAdapter(
              child: Animate(
                effects: const [
                  FadeEffect(
                      delay: Duration(milliseconds: 200),
                      duration: Duration(milliseconds: 600)),
                  SlideEffect(
                      delay: Duration(milliseconds: 200),
                      begin: Offset(0, 0.2),
                      end: Offset(0, 0)),
                ],
                child: Container(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 30),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(6, 6),
                        blurRadius: 12,
                      ),
                      const BoxShadow(
                        color: Colors.white,
                        offset: Offset(-6, -6),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Şair ara...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: accentColor,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                    ),
                    cursorColor: accentColor,
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
              ),
            ),

            // Poets Grid
            poetsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.indigo),
                ),
              ),
              error: (error, stackTrace) => SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade400,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bir hata oluştu: $error',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red.shade400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          ref.refresh(poetsProvider);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(4, 4),
                                blurRadius: 8,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-4, -4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            'Tekrar Dene',
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (poets) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final poet = poets[index];
                      return Animate(
                        effects: [
                          FadeEffect(
                            delay: Duration(milliseconds: 100 * index),
                            duration: const Duration(milliseconds: 500),
                          ),
                          SlideEffect(
                            delay: Duration(milliseconds: 100 * index),
                            duration: const Duration(milliseconds: 500),
                            begin: const Offset(0, 0.2),
                            end: const Offset(0, 0),
                          ),
                        ],
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PoetDetailPage(
                                    poet: _convertToModelPoet(poet)),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(6, 6),
                                  blurRadius: 12,
                                ),
                                const BoxShadow(
                                  color: Colors.white,
                                  offset: Offset(-6, -6),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Gradient header
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.indigo.shade800,
                                            Colors.indigo.shade600,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(24),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.format_quote,
                                          size: 40,
                                          color: Colors.white.withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                    // Content
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 40, 16, 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              poet.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.indigo.shade900,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.indigo.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.menu_book,
                                                    color: accentColor,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    '${poet.poemCount} şiir',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: accentColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Avatar
                                Positioned(
                                  top: 70,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            offset: const Offset(0, 4),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: poet.imageUrl != null &&
                                                  poet.imageUrl!.isNotEmpty
                                              ? Image.network(
                                                  poet.imageUrl!,
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      const Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Colors.indigo,
                                                  ),
                                                )
                                              : const Icon(
                                                  Icons.person,
                                                  size: 30,
                                                  color: Colors.indigo,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: poets.length,
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
