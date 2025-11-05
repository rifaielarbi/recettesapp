import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../utils/constants.dart';
import 'gamification_details_modal.dart';

class GamificationCarousel extends StatefulWidget {
  const GamificationCarousel({super.key});

  @override
  State<GamificationCarousel> createState() => _GamificationCarouselState();
}

class _GamificationCarouselState extends State<GamificationCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    final features = [
      _GamificationFeature(
        icon: Icons.explore,
        iconColor: const Color(0xFF2BB673),
        title: loc.recipeExplorerTitle,
        description: loc.recipeExplorerDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFF2BB673), Color(0xFF23956B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GamificationFeature(
        icon: Icons.emoji_events,
        iconColor: const Color(0xFFFFB800),
        title: loc.pointsBadgesTitle,
        description: loc.pointsBadgesDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB800), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GamificationFeature(
        icon: Icons.leaderboard,
        iconColor: const Color(0xFF6C63FF),
        title: loc.leaderboardTitle,
        description: loc.leaderboardDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GamificationFeature(
        icon: Icons.calendar_today,
        iconColor: const Color(0xFFFF6584),
        title: loc.dailyChallengesTitle,
        description: loc.dailyChallengesDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6584), Color(0xFFFF4567)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GamificationFeature(
        icon: Icons.photo_camera,
        iconColor: const Color(0xFF00C9FF),
        title: loc.photoSharingTitle,
        description: loc.photoSharingDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFF00C9FF), Color(0xFF00A8D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _GamificationFeature(
        icon: Icons.local_fire_department,
        iconColor: const Color(0xFFFF7A00),
        title: loc.mealStreaksTitle,
        description: loc.mealStreaksDesc,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7A00), Color(0xFFE86D00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.blue.shade50,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  loc.gamificationTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  loc.gamificationSubtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: features.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildFeatureCard(features[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              features.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.green
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                Text(
                  loc.swipeToExplore,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    GamificationDetailsModal.show(context);
                  },
                  icon: const Icon(Icons.info_outline, size: 16),
                  label: Text(
                    loc.learnMore,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(_GamificationFeature feature) {
    return Container(
      decoration: BoxDecoration(
        gradient: feature.gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: feature.iconColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                feature.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              feature.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              feature.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _GamificationFeature {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Gradient gradient;

  _GamificationFeature({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.gradient,
  });
}

