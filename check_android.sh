#!/bin/bash

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║         📱 Vérification de Connexion Android                  ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Ajouter ADB au PATH
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

echo "🔍 Étape 1: Vérification d'ADB..."
if command -v adb &> /dev/null; then
    echo "✅ ADB trouvé : $(adb version | head -n 1)"
else
    echo "❌ ADB non trouvé dans le PATH"
    echo "💡 Installez Android SDK ou ajoutez-le au PATH"
    exit 1
fi

echo ""
echo "🔄 Étape 2: Redémarrage du serveur ADB..."
adb kill-server > /dev/null 2>&1
adb start-server > /dev/null 2>&1
echo "✅ Serveur ADB redémarré"

echo ""
echo "📱 Étape 3: Recherche d'appareils Android..."
DEVICES=$(adb devices | grep -v "List of devices" | grep "device$" | wc -l | tr -d ' ')

if [ "$DEVICES" -gt 0 ]; then
    echo "✅ $DEVICES appareil(s) détecté(s) :"
    echo ""
    adb devices -l
    echo ""
    echo "🎉 Succès ! Votre téléphone est connecté."
    echo ""
    echo "▶️  Pour lancer l'app, exécutez :"
    echo "    flutter run"
else
    echo "❌ Aucun appareil détecté"
    echo ""
    echo "📋 Checklist de dépannage :"
    echo ""
    echo "  [ ] 1. Mode développeur activé sur le téléphone"
    echo "       Paramètres → À propos → Tapez 7 fois sur 'Numéro de build'"
    echo ""
    echo "  [ ] 2. Débogage USB activé"
    echo "       Paramètres → Options développeur → Débogage USB : ON"
    echo ""
    echo "  [ ] 3. Mode connexion = 'Transfert de fichiers' (MTP)"
    echo "       Glissez la notification USB → Sélectionnez MTP"
    echo ""
    echo "  [ ] 4. Popup d'autorisation acceptée"
    echo "       'Autoriser le débogage USB ?' → OK"
    echo ""
    echo "  [ ] 5. Câble USB supporte le transfert de données"
    echo "       Essayez un autre câble si nécessaire"
    echo ""
    echo "💡 Débranchez et rebranchez le câble, puis relancez ce script !"
    echo ""
    echo "📖 Guide complet : ANDROID_DEBUG_GUIDE.md"
fi

echo ""
echo "🔍 Étape 4: Vérification Flutter..."
flutter devices
