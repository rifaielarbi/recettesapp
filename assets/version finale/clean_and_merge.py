#!/usr/bin/env python3
# clean_and_merge.py
from pathlib import Path
import re, json, sys
from collections import Counter

BASE = Path('.')  # ex: "version finale"
letters = [chr(c) for c in range(ord('a'), ord('z')+1)]
all_meals = []

def robust_clean(text: str) -> str:
    # supprime virgules finales avant ] or }
    text = re.sub(r',\s*([}\]])', r'\1', text)
    # ajoute virgule entre objets collés }{
    text = re.sub(r'}\s*{', r'},{', text)
    # ajoute virgule entre tableaux collés ][
    text = re.sub(r'\]\s*\[', r'],[', text)
    return text

for L in letters:
    p = BASE / f'transformed_response.{L}.json'
    if not p.exists():
        continue
    raw = p.read_text(encoding='utf-8', errors='replace')
    cleaned = robust_clean(raw)
    try:
        data = json.loads(cleaned)
    except json.JSONDecodeError as e:
        print(f'[ERROR] {p.name}: JSON decode error: {e}')
        (p.with_suffix('.cleaned.json')).write_text(cleaned, encoding='utf-8')
        continue
    meals = data.get('meals') or []
    if isinstance(meals, dict):
        meals = [meals]
    all_meals.extend(meals)

# dédoublonnage par id (ou idMeal)
uniq = {}
for m in all_meals:
    mid = m.get('id') or m.get('idMeal') or m.get('ID') or None
    if not mid:
        # fallback: crée clé unique basée sur titre+pays
        mid = (m.get('titre') or m.get('name','')) + '||' + (m.get('pays') or '')
    uniq[mid] = m

unique = list(uniq.values())
out = {'meals': unique}
out_path = BASE / 'recettes_a_to_z.json'
out_path.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding='utf-8')
print(f'[OK] Wrote {len(unique)} unique recipes to {out_path}')

# rapport rapide
countries = Counter((m.get('pays') or '—').strip() for m in unique)
missing_image = sum(1 for m in unique if not m.get('image'))
missing_youtube = sum(1 for m in unique if not m.get('youtube'))
print('Top countries:', countries.most_common(10))
print('Missing image count:', missing_image)
print('Missing youtube count:', missing_youtube)