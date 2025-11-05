import 'package:flutter/material.dart';
import '../app_localizations.dart';
import '../utils/constants.dart';

class GamificationDetailsModal extends StatelessWidget {
  const GamificationDetailsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GamificationDetailsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.gamificationTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.gamificationSubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFeatureSection(
                      icon: Icons.explore,
                      iconColor: const Color(0xFF2BB673),
                      title: loc.recipeExplorerTitle,
                      description: loc.recipeExplorerDesc,
                      benefits: [
                        '🌍 Discover 30+ countries',
                        '🍳 Unlock exclusive cuisines',
                        '🏆 Complete cooking challenges',
                        '⭐ Earn country badges',
                      ],
                    ),
                    
                    _buildFeatureSection(
                      icon: Icons.emoji_events,
                      iconColor: const Color(0xFFFFB800),
                      title: loc.pointsBadgesTitle,
                      description: loc.pointsBadgesDesc,
                      benefits: [
                        '💯 Earn points for every recipe',
                        '🏅 Collect unique badges',
                        '📈 Track your progress',
                        '🎯 Achieve milestones',
                      ],
                    ),
                    
                    _buildFeatureSection(
                      icon: Icons.leaderboard,
                      iconColor: const Color(0xFF6C63FF),
                      title: loc.leaderboardTitle,
                      description: loc.leaderboardDesc,
                      benefits: [
                        '🥇 Compete with friends',
                        '📊 Weekly rankings',
                        '👑 Global Chef title',
                        '🤝 Join cooking communities',
                      ],
                    ),
                    
                    _buildFeatureSection(
                      icon: Icons.calendar_today,
                      iconColor: const Color(0xFFFF6584),
                      title: loc.dailyChallengesTitle,
                      description: loc.dailyChallengesDesc,
                      benefits: [
                        '📅 New challenge daily',
                        '🎁 Bonus rewards',
                        '🌟 Special event challenges',
                        '💪 Build cooking habits',
                      ],
                    ),
                    
                    _buildFeatureSection(
                      icon: Icons.photo_camera,
                      iconColor: const Color(0xFF00C9FF),
                      title: loc.photoSharingTitle,
                      description: loc.photoSharingDesc,
                      benefits: [
                        '📸 Share your creations',
                        '❤️ Get community likes',
                        '💬 Receive feedback',
                        '🎨 Inspire others',
                      ],
                    ),
                    
                    _buildFeatureSection(
                      icon: Icons.local_fire_department,
                      iconColor: const Color(0xFFFF7A00),
                      title: loc.mealStreaksTitle,
                      description: loc.mealStreaksDesc,
                      benefits: [
                        '🔥 Build daily streaks',
                        '💪 Stay motivated',
                        '🥗 Track healthy meals',
                        '🎯 Reach nutrition goals',
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Get Started Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          loc.getStarted,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> benefits,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.substring(0, 2),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit.substring(2).trim(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

