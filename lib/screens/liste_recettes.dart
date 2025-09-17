import 'package:flutter/material.dart';
import '../models/recette.dart';
import '../utils/constants.dart';
import '../widgets/recette_card.dart';
import 'detail_recette.dart';

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
        : _all.where((r) => r.pays.toLowerCase() == _country.toLowerCase()).toList();
    if (_search.isEmpty) return byCountry;
    final q = _search.toLowerCase();
    return byCountry
        .where((r) => r.titre.toLowerCase().contains(q) || r.description.toLowerCase().contains(q))
        .toList();
  }

  void _openCountryFilter() async {
    final countries = ['Tous', ...{for (final r in _all) r.pays}];
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            const ListTile(title: Text('Filtrer par pays')),
            for (final c in countries)
              RadioListTile<String>(
                value: c,
                groupValue: _country,
                onChanged: (v) => Navigator.pop(context, v),
                title: Text(c),
              ),
          ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              titleSpacing: 16,
              title: Row(
                children: [
                  Image.asset(AppAssets.logo, width: 32, height: 32),
                  const SizedBox(width: 8),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Recettes', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
                      Text('Mondiales', style: TextStyle(color: Colors.black87)),
                    ],
                  ),
                ],
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    tooltip: 'Trier/Filtrer',
                    icon: const Icon(Icons.filter_list, color: Colors.black87),
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
                    Text('Recettes', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher une recette...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _search.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchCtrl.clear(),
                              ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 16, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text('Pays: $_country', style: const TextStyle(color: Colors.black54)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _openCountryFilter,
                          icon: const Icon(Icons.filter_list),
                          label: const Text('Filtrer'),
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
        selectedItemColor: AppColors.green,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Recettes'),
          BottomNavigationBarItem(icon: Icon(Icons.star_border), label: 'Favoris'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Param'),
        ],
      ),
    );
  }
}

