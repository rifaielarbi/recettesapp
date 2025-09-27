import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_localizations.dart';
import '../models/recette.dart';
import '../utils/constants.dart';
import '../widgets/recette_card.dart';
import '../providers/locale_provider.dart';
import 'detail_recette.dart';
import 'settings_screen.dart';

class ListeRecettesScreen extends StatefulWidget {
  const ListeRecettesScreen({super.key});

  @override
  State<ListeRecettesScreen> createState() => _ListeRecettesScreenState();
}

class _ListeRecettesScreenState extends State<ListeRecettesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String _country = 'Tous';

  // ----------------- Recettes -----------------
  List<Recette> get _all => const [
    Recette(
      id: '1',
      titre: 'Pasta Primavera',
      pays: 'Italie',
      image: AppAssets.pasta,
      description:
          "Un plat de pâtes aux légumes de saison avec une sauce légère à base d'huile d'olive.",
      ingredients: ['200 g de pâtes', '1 brocoli', '1 carotte'],
    ),
    Recette(
      id: '2',
      titre: 'Tacos Al Pastor',
      pays: 'Mexico',
      image: AppAssets.tacos,
      description: 'Tacos savoureux avec porc mariné, ananas et coriandre.',
      ingredients: ['Tortillas', 'Porc', 'Ananas'],
    ),
  ];

  // ----------------- Filtrage -----------------
  List<Recette> get _filtered {
    final byCountry =
        _country == 'Tous'
            ? _all
            : _all
                .where((r) => r.pays.toLowerCase() == _country.toLowerCase())
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

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ----------------- Utils -----------------
  Color? _withAlpha(Color? color, double opacity) {
    if (color == null) return null;
    return color.withAlpha((opacity * 255).round());
  }

  String _flagForCountry(String country) {
    switch (country) {
      case 'Italie':
        return '🇮🇹';
      case 'Mexico':
        return '🇲🇽';
      case 'Maroc':
        return '🇲🇦';
      case 'France':
        return '🇫🇷';
      default:
        return '🌍';
    }
  }

  // ----------------- Filtre Pays -----------------
  void _openCountryFilter() async {
    final countries = [
      'Tous',
      ...{for (final r in _all) r.pays},
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
                  Text(
                    'Filtrer par pays',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...countries.map(
                    (c) => ListTile(
                      title: Text(
                        "$c ${_flagForCountry(c)}", // 👉 Pays + Drapeau
                        style: const TextStyle(color: Colors.black87),
                      ),
                      trailing:
                          _country == c
                              ? const Icon(Icons.check, color: Colors.green)
                              : null,
                      onTap: () => Navigator.pop(context, c),
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
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // --- AppBar ---
            SliverAppBar(
              pinned: true,
              elevation: 1,
              backgroundColor: Colors.white,
              titleSpacing: 16,
              title: Row(
                children: [
                  Image.asset(AppAssets.logo, width: 32, height: 32),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).recipes,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        AppLocalizations.of(context).world,
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.language, color: textColor),
                  onSelected: localeProvider.setLocale,
                  itemBuilder:
                      (ctx) => const [
                        PopupMenuItem(value: 'fr', child: Text('Français')),
                        PopupMenuItem(value: 'en', child: Text('English')),
                        PopupMenuItem(value: 'ar', child: Text('العربية')),
                      ],
                ),
                IconButton(
                  icon: Icon(Icons.filter_list, color: textColor),
                  tooltip: 'Trier/Filtrer',
                  onPressed: _openCountryFilter,
                ),
              ],
            ),

            // --- Recherche + Filtre ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "${AppLocalizations.of(context).country}: $_country ${_flagForCountry(_country)}",
                          style: TextStyle(color: _withAlpha(textColor, 0.7)),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openCountryFilter,
                          icon: Icon(Icons.filter_list, color: textColor),
                          label: Text(
                            AppLocalizations.of(context).filter,
                            style: TextStyle(color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- Liste Recettes ---
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
                : SliverList.builder(
                  itemCount: _filtered.length,
                  itemBuilder: (context, index) {
                    final r = _filtered[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RecetteCard(
                        recette: r,
                        onVoirDetails:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DetailRecetteScreen(recette: r),
                              ),
                            ),
                      ),
                    );
                  },
                ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),

      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.restaurant_menu),
            label: AppLocalizations.of(context).recipes,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.star_border),
            label: AppLocalizations.of(context).favorites,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: AppLocalizations.of(context).settingsMenu,
          ),
        ],
      ),
    );
  }
}
