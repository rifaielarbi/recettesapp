import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesButton extends StatefulWidget {
  final String recipeId;

  const FavoritesButton({super.key, required this.recipeId});

  @override
  _FavoritesButtonState createState() => _FavoritesButtonState();
  }

class _FavoritesButtonState extends State<FavoritesButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  void _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.getBool('favorite_${widget.recipeId}') ?? false;
    });
  }


  void _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // Sauvegarder le nouvel état de favori
    prefs.setBool('favorite_${widget.recipeId}', _isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
        color: _isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: _toggleFavorite,
    );
  }
}