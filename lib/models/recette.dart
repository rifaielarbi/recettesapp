class Recette {
  final String id;
  final String titre;
  final String pays;
  final String image;
  final String description;
  final List<String> ingredients;

  const Recette({
    required this.id,
    required this.titre,
    required this.pays,
    required this.image,
    required this.description,
    required this.ingredients,
  });
}


