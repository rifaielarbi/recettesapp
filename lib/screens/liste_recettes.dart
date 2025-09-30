import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import '../app_localizations.dart';
import '../models/recette.dart';
import '../utils/constants.dart';
import '../widgets/recette_card.dart';
import 'detail_recette.dart';
import '../providers/locale_provider.dart';

class ListeRecettesScreen extends StatefulWidget {
  const ListeRecettesScreen({super.key});

  @override
  State<ListeRecettesScreen> createState() => _ListeRecettesScreenState();
}

class _ListeRecettesScreenState extends State<ListeRecettesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';
  String _country = 'Tous';

  List<Recette> _recipesFromJson = [];
  bool _loading = true;
  int _currentIndex = 0; // Pour BottomNavigationBar

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

  Future<void> _loadRecipesFromJson() async {
    final jsonStr =
    await rootBundle.loadString('assets/data/recettes_a_to_z.json');
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;
    final List<dynamic> meals = data['meals'] ?? [];

    setState(() {
      _recipesFromJson = meals
          .map((m) => Recette(
        id: m['id'] ?? '',
        titre: m['titre'] ?? m['name'] ?? 'Sans titre',
        pays: m['pays'] ?? 'Inconnu',
        image: m['image'] ?? AppAssets.pasta,
        description: m['description'] ?? '',
        ingredients: (m['ingredients'] as List<dynamic>?)
            ?.map((i) => i.toString())
            .toList() ??
            [],
      ))
          .toList();
      _loading = false;
    });
  }

  List<Recette> get _all => _loading ? [] : _recipesFromJson;

  List<Recette> get _filtered {
    final byCountry = _country == 'Tous'
        ? _all
        : _all
        .where((r) => r.pays.toLowerCase() == _country.toLowerCase())
        .toList();

    if (_search.isEmpty) return byCountry;
    final q = _search.toLowerCase();
    return byCountry
        .where((r) =>
    r.titre.toLowerCase().contains(q) ||
        r.description.toLowerCase().contains(q))
        .toList();
  }

  void _openCountryFilter() async {
    final countries = ['Tous', ...{for (final r in _all) r.pays}];

    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context).filterByCountry,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              ...countries.map(
                    (c) => ListTile(
                  title: Text(
                    c,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  trailing: _country == c
                      ? Icon(Icons.check,
                      color: Theme.of(context).colorScheme.primary)
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

  Color? _withAlpha(Color? color, double opacity) {
    if (color == null) return null;
    return color.withAlpha((opacity * 255).round());
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0:
      // Recettes : reste sur cet écran
        break;
      case 1:
      // Favoris : remplacer par ton écran favoris
        Navigator.pushNamed(context, '/favorites');
        break;
      case 2:
      // Paramètres
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor:
              theme.appBarTheme.backgroundColor ?? colorScheme.surface,
              elevation: 0,
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
                            color: textColor, fontWeight: FontWeight.w700),
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
                  icon: Icon(Icons.language,
                      color: theme.iconTheme.color ?? textColor),
                  onSelected: (lang) {
                    localeProvider.setLocale(lang);
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(value: 'fr', child: Text('Français')),
                    PopupMenuItem(value: 'en', child: Text('English')),
                    PopupMenuItem(value: 'ar', child: Text('العربية')),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    tooltip: 'Trier/Filtrer',
                    icon: Icon(Icons.filter_list,
                        color: theme.iconTheme.color ?? textColor),
                    onPressed: _openCountryFilter,
                  ),
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context).recipes,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: textColor,
                        )),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).searchRecipe,
                        hintStyle:
                        TextStyle(color: _withAlpha(textColor, 0.6)),
                        prefixIcon: Icon(Icons.search,
                            color: theme.iconTheme.color ?? textColor),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                          icon: Icon(Icons.clear,
                              color: theme.iconTheme.color ?? textColor),
                          onPressed: () => _searchCtrl.clear(),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverList.builder(
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final r = _filtered[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RecetteCard(
                    recette: r,
                    onVoirDetails: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailRecetteScreen(recette: r),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor:
        theme.bottomNavigationBarTheme.backgroundColor ?? colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        onTap: _onBottomNavTap,
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