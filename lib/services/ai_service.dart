
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recette_service.dart';

class AiService {
  AiService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  final String _apiKey = const String.fromEnvironment('OPENAI_API_KEY');
  final String _baseUrl = const String.fromEnvironment('OPENAI_BASE', defaultValue: 'https://api.openai.com');
  final String _model = const String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4o-mini');

  Future<String> ask(String prompt) async {
    if (_apiKey.isEmpty || _apiKey.contains('your-') || _apiKey.contains('xxxxx')) {
      return 'Clé API manquante ou placeholder. Modifiez dart_defines.json et relancez.';
    }
    
    // Charger les recettes disponibles
    await RecetteService.getRecettes();
    final recettesInfo = RecetteService.getRecettesAsString();
    
    final systemPrompt = '''Tu es un assistant culinaire spécialisé dans les recettes de l'application. 
Tu as accès à une base de données de recettes du monde entier.

$recettesInfo

Réponds aux questions des utilisateurs en te basant sur ces recettes. Si l'utilisateur demande des recettes qui ne sont pas dans la liste, suggère des recettes similaires ou des alternatives disponibles. Sois précis et utile dans tes réponses.''';

    final uri = Uri.parse('$_baseUrl/v1/chat/completions');
    final res = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.2,
      }),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final content = (data['choices'] as List).first['message']['content'] as String;
      return content.trim();
    }
    if (res.statusCode == 401) return 'Clé API invalide (401). Vérifiez OPENAI_API_KEY.';
    if (res.statusCode == 429) return 'Quota dépassé (429). Ajoutez du crédit ou réessayez plus tard.';
    return 'Erreur API (${res.statusCode}): ${res.body}';
  }
}
