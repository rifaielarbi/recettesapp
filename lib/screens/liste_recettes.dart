import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../app_localizations.dart';
import '../models/recette.dart';
import '../utils/constants.dart';
import '../widgets/compact_recipe_card.dart';
import 'detail_recette.dart';
import 'settings_screen.dart';
import 'chat_screen.dart';
import 'favorites_screen.dart';

class ListeRecettesScreen extends StatefulWidget {
  const ListeRecettesScreen({super.key});

  @override
  State<ListeRecettesScreen> createState() => _ListeRecettesScreenState();
}

class _ListeRecettesScreenState extends State<ListeRecettesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String _country = 'Tous';
  int _currentIndex = 0;

  List<Recette> _all = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
    _loadRecipesFromJson();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ----------------- Chargement JSON -----------------
  Future<void> _loadRecipesFromJson() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/recettes_a_to_z.json',
      );
      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
      final List<dynamic> meals = jsonData['meals'] ?? [];

      setState(() {
        _all = meals.map((m) => Recette.fromJson(m)).toList();
      });

      print("Chargement terminé : ${_all.length} recettes");
    } catch (e) {
      debugPrint("Erreur de chargement des recettes: $e");
    }
  }

  // ----------------- Normalisation -----------------
  String normalizeCountry(String c) {
    switch (c.toLowerCase().trim()) {
      case 'maroc':
      case 'moroccan':
        return 'Maroc';
      case 'france':
      case 'french':
        return 'France';
      case 'italie':
      case 'italian':
        return 'Italie';
      case 'mexique':
      case 'mexican':
        return 'Mexique';
      case 'usa':
      case 'us':
      case 'american':
        return 'États-Unis';
      case 'thaïlande':
      case 'thailand':
      case 'thai':
        return 'Thaïlande';
      case 'tunisie':
      case 'tunisian':
        return 'Tunisie';
      case 'japon':
      case 'japanese':
        return 'Japon';
      case 'royaume-uni':
      case 'british':
        return 'Royaume-Uni';
      case 'malaisie':
      case 'malaysian':
        return 'Malaisie';
      case 'russie':
      case 'russian':
        return 'Russie';
      case 'canada':
      case 'canadian':
        return 'Canada';
      case 'jamaïque':
      case 'jamaican':
        return 'Jamaïque';
      case 'chine':
      case 'chinese':
        return 'Chine';
      case 'pays-bas':
      case 'dutch':
        return 'Pays-Bas';
      case 'vietnam':
      case 'vietnamese':
        return 'Vietnam';
      case 'pologne':
      case 'polish':
        return 'Pologne';
      case 'irlande':
      case 'irish':
        return 'Irlande';
      case 'croatie':
      case 'croatian':
        return 'Croatie';
      case 'philippines':
      case 'filipino':
        return 'Philippines';
      case 'ukraine':
      case 'ukrainian':
        return 'Ukraine';
      case 'turquie':
      case 'turkish':
        return 'Turquie';
      case 'grèce':
      case 'greek':
        return 'Grèce';
      case 'uruguay':
      case 'uruguayan':
        return 'Uruguay';
      case 'égypte':
      case 'egyptian':
        return 'Égypte';
      case 'portugal':
      case 'portuguese':
        return 'Portugal';
      case 'espagne':
      case 'spanish':
        return 'Espagne';
      case 'inde':
      case 'indian':
        return 'Inde';
      case 'kenya':
      case 'kenyan':
        return 'Kenya';
      case 'tous':
        return 'Tous';
      default:
        return c.trim();
    }
  }

  // ----------------- Filtrage -----------------
  List<Recette> get _filtered {
    final byCountry =
        _country == 'Tous'
            ? _all
            : _all
                .where(
                  (r) => normalizeCountry(r.pays) == normalizeCountry(_country),
                )
                .toList();

    if (_search.isEmpty) return byCountry;

    final q = _search.toLowerCase();
    return byCountry
        .where(
          (r) =>
              r.titre.toLowerCase().contains(q) ||
              r.description.toLowerCase().contains(q),
        )
        .toList();
  }

  // ----------------- Utils -----------------
  Color? _withAlpha(Color? color, double opacity) {
    if (color == null) return null;
    return color.withAlpha((opacity * 255).round());
  }

  String _flagForCountry(String country) {
    switch (country) {
      case 'Maroc':
        return '🇲🇦 Maroc';
      case 'France':
        return '🇫🇷 France';
      case 'Italie':
        return '🇮🇹 Italie';
      case 'Mexique':
        return '🇲🇽 Mexique';
      case 'États-Unis':
        return '🇺🇸 États-Unis';
      case 'Thaïlande':
        return '🇹🇭 Thaïlande';
      case 'Tunisie':
        return '🇹🇳 Tunisie';
      case 'Japon':
        return '🇯🇵 Japon';
      case 'Royaume-Uni':
        return '🇬🇧 Royaume-Uni';
      case 'Malaisie':
        return '🇲🇾 Malaisie';
      case 'Russie':
        return '🇷🇺 Russie';
      case 'Canada':
        return '🇨🇦 Canada';
      case 'Jamaïque':
        return '🇯🇲 Jamaïque';
      case 'Chine':
        return '🇨🇳 Chine';
      case 'Pays-Bas':
        return '🇳🇱 Pays-Bas';
      case 'Vietnam':
        return '🇻🇳 Vietnam';
      case 'Pologne':
        return '🇵🇱 Pologne';
      case 'Irlande':
        return '🇮🇪 Irlande';
      case 'Croatie':
        return '🇭🇷 Croatie';
      case 'Philippines':
        return '🇵🇭 Philippines';
      case 'Ukraine':
        return '🇺🇦 Ukraine';
      case 'Turquie':
        return '🇹🇷 Turquie';
      case 'Grèce':
        return '🇬🇷 Grèce';
      case 'Uruguay':
        return '🇺🇾 Uruguay';
      case 'Égypte':
        return '🇪🇬 Égypte';
      case 'Portugal':
        return '🇵🇹 Portugal';
      case 'Espagne':
        return '🇪🇸 Espagne';
      case 'Inde':
        return '🇮🇳 Inde';
      case 'Kenya':
        return '🇰🇪 Kenya';
      case 'Tous':
        return '🌍 Tous';
      default:
        return '🌍 $country';
    }
  }

  // ----------------- Filtre Pays -----------------
  void _openCountryFilter() async {
    final countries = [
      'Tous',
      ...{for (final r in _all) normalizeCountry(r.pays)},
    ];

    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filtrer par pays',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // ← Wrap la liste dans Flexible + SingleChildScrollView
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children:
                            countries
                                .map(
                                  (c) => ListTile(
                                    title: Text(
                                      _flagForCountry(c),
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    trailing:
                                        _country == c
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            )
                                            : null,
                                    onTap: () => Navigator.pop(context, c),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );

    if (chosen != null && mounted) setState(() => _country = chosen);
  }

  // ----------------- UI -----------------
  Widget _buildRecettesScreen(BuildContext context, Color? textColor) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bonjour + Recherche
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6EE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bonjour Arabi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Que Préparez-Vous Aujourd\'hui ?',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.notifications_none, color: Colors.black87),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recherche
                TextField(
                  controller: _searchCtrl,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).searchRecipe,
                    hintStyle: TextStyle(color: _withAlpha(textColor, 0.5)),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.search, color: textColor),
                    suffixIcon:
                        _search.isEmpty
                            ? null
                            : IconButton(
                              icon: Icon(Icons.clear, color: textColor),
                              onPressed: () => _searchCtrl.clear(),
                            ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Catégories + filtre
                Row(
                  children: [
                    const Text(
                      'Catégorie',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: _openCountryFilter,
                      child: Row(
                        children: const [
                          Icon(Icons.tune, size: 18, color: Colors.green),
                          SizedBox(width: 6),
                          Text(
                            'Filtrer',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Chip "Tous"
                      _CategoryChip(
                        label: _flagForCountry('Tous'),
                        selected: _country == 'Tous',
                        onTap: () => setState(() => _country = 'Tous'),
                      ),
                      // Chips pour chaque pays existant dans _all
                      ...{for (final r in _all) normalizeCountry(r.pays)}.map(
                        (p) => _CategoryChip(
                          label: _flagForCountry(p),
                          selected: _country == p,
                          onTap: () => setState(() => _country = p),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text(
                      'Recettes Populaires',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Voir Tout'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Liste
        _filtered.isEmpty
            ? SliverFillRemaining(
              child: Center(
                child: Text(
                  "Aucune recette trouvée",
                  style: TextStyle(
                    fontSize: 16,
                    color: _withAlpha(textColor, 0.7),
                  ),
                ),
              ),
            )
            : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final r = _filtered[index];
                  return CompactRecipeCard(
                    recette: r,
                    onTap:
                        () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DetailRecetteScreen(recette: r),
                          ),
                        ),
                  );
                }, childCount: _filtered.length),
              ),
            ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildRecettesScreen(context, textColor),
            FavoritesScreen(allRecipes: _all),
            const SettingsScreen(),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton:
          _currentIndex == 0
              ? FloatingActionButton.extended(
                onPressed:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChatScreen()),
                    ),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Assistant'),
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
              )
              : null,

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _UltraModernNavItem(
                icon: Icons.home_rounded,
                label: 'Accueil',
                selected: _currentIndex == 0,
                onTap: () => setState(() => _currentIndex = 0),
              ),
              _UltraModernNavItem(
                icon: Icons.favorite_rounded,
                label: 'Favoris',
                selected: _currentIndex == 1,
                onTap: () => setState(() => _currentIndex = 1),
              ),
              _UltraModernNavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                selected: _currentIndex == 2,
                onTap: () => setState(() => _currentIndex = 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ----------------- Widget Chip -----------------
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const _CategoryChip({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- Widget Nav -----------------
class _UltraModernNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UltraModernNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 20 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
