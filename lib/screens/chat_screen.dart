import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/ai_service.dart';
import '../services/recette_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Message> _messages = <_Message>[
    _Message(role: 'assistant', text: 'Bonjour! Posez une question sur une recette.'),
  ];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  List<_Recette> _recipes = const [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recettes = await RecetteService.getRecettes();
      setState(() {
        _recipes = recettes.map((r) => _Recette(
          id: r.id,
          titre: r.titre,
          pays: r.pays,
          image: r.image,
          description: r.description,
          ingredients: r.ingredients,
        )).toList();
      });
    } catch (_) {
      // ignore
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Assistant Recettes (offline)')),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: isUser ? cs.primary : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Text(
                          m.text,
                          style: TextStyle(color: isUser ? cs.onPrimary : cs.onSurface),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Posez votre question... '),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _sending ? null : _onSend,
                  icon: _sending
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Message(role: 'user', text: text));
      _controller.clear();
      _sending = true;
    });

    final reply = _offlineAnswer(text);
    setState(() {
      _messages.add(_Message(role: 'assistant', text: reply));
      _sending = false;
    });
  }

  String _offlineAnswer(String q) {
    final query = q.toLowerCase();
    // Si l'utilisateur dit bonjour, répondre et lister les ingrédients de chaque recette
    if (query.contains('bonjour')) {
      final buf = StringBuffer('Bonjour! Voici les ingrédients de vos recettes:\n');
      for (final r in _recipes) {
        buf.writeln('\n${r.titre} (${r.pays})');
        for (final ing in r.ingredients) {
          buf.writeln('- $ing');
        }
      }
      if (_recipes.isEmpty) buf.writeln('\n(Aucune recette locale chargée)');
      return buf.toString();
    }

    // Sinon, trouver la recette la plus pertinente par mots-clés et lister ses ingrédients
    if (_recipes.isEmpty) return "Je n'ai pas trouvé de données locales.";

    _Recette? best;
    int bestScore = -1;
    for (final r in _recipes) {
      final hay = (r.titre + ' ' + r.description + ' ' + r.ingredients.join(' ')).toLowerCase();
      int score = 0;
      for (final token in query.split(RegExp(r'[^a-zA-Zà-ÿ0-9]+')).where((t) => t.isNotEmpty)) {
        if (hay.contains(token)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        best = r;
      }
    }

    if (best == null || bestScore == 0) {
      return "Je n'ai pas trouvé de recette correspondante. Essayez un nom (ex: Pasta, Tacos).";
    }

    final buf = StringBuffer()
      ..writeln('Recette: ${best.titre} (${best.pays})')
      ..writeln('Ingrédients:');
    for (final ing in best.ingredients) {
      buf.writeln('- $ing');
    }
    return buf.toString();
  }
}

class _Message {
  final String role;
  final String text;
  _Message({required this.role, required this.text});
}

class _Recette {
  final String id;
  final String titre;
  final String pays;
  final String image;
  final String description;
  final List<String> ingredients;

  const _Recette({
    required this.id,
    required this.titre,
    required this.pays,
    required this.image,
    required this.description,
    required this.ingredients,
  });

  factory _Recette.fromJson(Map<String, dynamic> json) => _Recette(
        id: json['id'] as String,
        titre: json['titre'] as String,
        pays: json['pays'] as String,
        image: json['image'] as String? ?? '',
        description: json['description'] as String? ?? '',
        ingredients: (json['ingredients'] as List<dynamic>).map((e) => e as String).toList(),
      );
}
