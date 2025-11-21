import json
import re
import string
import os


# Dossier où se trouvent les fichiers JSON
folder_path = "."

# Préfixe et extension des fichiers
prefix = "transformed_response"
extension = ".json"

# Nom du fichier final fusionné
output_file = "recettes_a_to_z.json"

# Liste qui va contenir toutes les recettes
all_meals = []

# Boucle sur les lettres a → z
for letter in string.ascii_lowercase:
    filename = f"{prefix}.{letter}{extension}"
    filepath = os.path.join(folder_path, filename)

    if os.path.exists(filepath):
        with open(filepath, "r", encoding="utf-8") as f:
            text = f.read()
            # Nettoyage robuste : supprime les virgules avant ] ou }
            text = re.sub(r",\s*([\]}])", r"\1", text)
            # Ajoute une virgule manquante entre } { ou ] [
            text = re.sub(r"}\s*{", "},{", text)
            text = re.sub(r"]\s*\[", "],[", text)
            try:
                data = json.loads(text)
                if "meals" in data:
                    all_meals.extend(data["meals"])
                print(f" Fichier fusionné : {filename}")
            except json.JSONDecodeError as e:
                print(f" Erreur JSON dans {filename} : {e}")
                # Optionnel : sauvegarder le texte nettoyé pour inspection
                with open(f"{filename}_cleaned.json", "w", encoding="utf-8") as cf:
                    cf.write(text)
                print(f" Texte nettoyé sauvegardé dans {filename}_cleaned.json")
    else:
        print(f"⚠️ Fichier introuvable : {filename}")

# Sauvegarde du fichier fusionné
with open(output_file, "w", encoding="utf-8") as f:
    json.dump({"meals": all_meals}, f, ensure_ascii=False, indent=2)

print(f"\n Fusion terminée ({len(all_meals)} recettes) dans {output_file}")
