import '../models/recette.dart';
import '../utils/constants.dart';

class RecetteService {
  const RecetteService._();

  static const List<Recette> all = [
    Recette(
      id: '1',
      titre: 'Pasta Primavera',
      pays: 'Italie',
      image: AppAssets.pasta,
      description: "Un plat de pâtes aux légumes de saison avec une sauce légère à base d'huile d'olive.",
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
}


