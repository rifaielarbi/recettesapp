#!/usr/bin/env python3
# normalize_recipes.py
import json
from pathlib import Path
import re

BASE = Path('.')
in_file = BASE / 'recettes_a_to_z.json'
out_file = BASE / 'recettes_a_to_z_cleaned.json'

# 📑 Mappings : catégories, tags, unités…
CATEGORY_MAP = {
    'Desert': 'Dessert',
    'Deserts': 'Dessert',
    'Entrée': 'Entrée',
    # ajoute ici tes propres corrections
}

UNIT_MAP = {
    'tbs': 'tbsp',
    'tbsp.': 'tbsp',
    'Tbsp': 'tbsp',
    'tablespoon': 'tbsp',
    # ajoute ici tes propres corrections
}

PLACEHOLDER_IMAGE = 'https://via.placeholder.com/300x200.png?text=No+Image'

def clean_text(text):
    if not text:
        return text
    # Supprime HTML simple
    text = re.sub(r'<[^>]+>', '', text)
    # Supprime numérotation type "1)" ou "1."
    text = re.sub(r'^\s*\d+[\)\.]\s*', '', text)
    return text.strip()

# Charger le JSON
data = json.loads(in_file.read_text(encoding='utf-8'))
meals = data.get('meals', [])

for m in meals:
    # 🔹 Catégorie
    cat = m.get('categorie') or m.get('category')
    if cat in CATEGORY_MAP:
        m['categorie'] = CATEGORY_MAP[cat]

    # 🔹 Tags
    tags = m.get('tags')
    if isinstance(tags, str):
        tags = [t.strip() for t in tags.split(',')]
    if isinstance(tags, list):
        m['tags'] = [CATEGORY_MAP.get(t, t) for t in tags]

    # 🔹 Unités dans ingrédients
    ingredients = m.get('ingredients') or []
    if isinstance(ingredients, list):
        new_ing = []
        for ing in ingredients:
            new_ing.append(_normalize_units(ing))
        m['ingredients'] = new_ing

    # 🔹 Nettoyage description
    m['description'] = clean_text(m.get('description'))

    # 🔹 Image placeholder si vide
    if not m.get('image'):
        m['image'] = PLACEHOLDER_IMAGE

def _normalize_units(ing_line: str) -> str:
    """Remplace les unités selon UNIT_MAP"""
    s = ing_line
    for bad, good in UNIT_MAP.items():
        s = re.sub(rf'\b{bad}\b', good, s, flags=re.IGNORECASE)
    return s

# Sauvegarde
out_file.write_text(json.dumps({'meals': meals}, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'[OK] Normalisation terminée. Fichier écrit : {out_file}')