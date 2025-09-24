import 'package:flutter/material.dart';
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
                      ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.primary,
                  )
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

  Color? _withAlpha(Color? color, double opacity) {
    if (color == null) return null;
    return color.withAlpha((opacity * 255).round());
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
        child: CustomScrollView(
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
                        hintStyle: TextStyle(
                            color: _withAlpha(textColor, 0.6)),
                        prefixIcon: Icon(Icons.search,
                            color: theme.iconTheme.color ?? textColor),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                          icon: Icon(Icons.clear,
                              color:
                              theme.iconTheme.color ?? textColor),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.flag,
                            size: 16,
                            color: _withAlpha(
                                theme.iconTheme.color, 0.6) ??
                                _withAlpha(textColor, 0.6)),
                        const SizedBox(width: 6),
                        Text(
                          '${AppLocalizations.of(context).country}: $_country',
                          style: TextStyle(
                              color: _withAlpha(textColor, 0.6)),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openCountryFilter,
                          icon: Icon(Icons.filter_list,
                              color: theme.iconTheme.color ?? textColor),
                          label: Text(AppLocalizations.of(context).filter,
                              style: TextStyle(color: textColor)),
                        ),
                      ],
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
        currentIndex: 0,
        backgroundColor:
        theme.bottomNavigationBarTheme.backgroundColor ?? colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: theme.unselectedWidgetColor,
        onTap: (index) {
          if (index == 2) {
            Navigator.pushNamed(context, '/settings');
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