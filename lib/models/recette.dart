class Recette {
  final String id;
  final String titre;
  final String categorie;
  final String pays;
  final String image;
  final String description;
  final List<String> ingredients;
  final List<String> tags;
  final String youtube;

  Recette({
    required this.id,
    required this.titre,
    this.categorie = '',
    this.pays = 'Inconnu',
    this.image = '',
    this.description = '',
    this.ingredients = const [],
    this.tags = const [],
    this.youtube = '',
  });

  factory Recette.fromJson(Map<String, dynamic> json) {
    return Recette(
      id: json['id']?.toString() ?? '',
      titre:
          json['titre']?.toString() ?? json['name']?.toString() ?? 'Sans titre',
      categorie: json['categorie']?.toString() ?? '',
      pays: json['pays']?.toString() ?? 'Inconnu',
      image: json['image']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ingredients:
          (json['ingredients'] as List<dynamic>?)
              ?.map((i) => i.toString())
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)?.map((t) => t.toString()).toList() ??
          [],
      youtube: json['youtube']?.toString() ?? '',
    );
  }
}
