# 📱 Guide de Débogage Android - Connexion USB

## ❌ Problème : Téléphone Android Non Détecté

### 🔍 Diagnostic Actuel
- ✅ Flutter installé correctement
- ✅ Android SDK installé
- ✅ ADB fonctionne
- ❌ **Aucun appareil détecté**

---

## ✅ Solutions (Suivez dans l'ordre)

### 📋 **ÉTAPE 1 : Activer le Débogage USB**

#### Sur votre téléphone Android :

1. **Ouvrir les Options pour les Développeurs** :
   ```
   Paramètres → Système → Options pour les développeurs
   
   OU
   
   Paramètres → À propos du téléphone
   → Tapez 7 fois sur "Numéro de build"
   → Retournez et trouvez "Options pour les développeurs"
   ```

2. **Activer ces options** :
   - ✅ **Options pour les développeurs** : ON
   - ✅ **Débogage USB** : ON
   - ✅ **Installation via USB** : ON (si disponible)
   - ✅ **Autoriser le débogage USB (mode sécurisé)** : ON (si disponible)

3. **Vérifier l'icône USB** :
   - Une icône USB devrait apparaître dans la barre de notification

---

### 🔌 **ÉTAPE 2 : Vérifier le Mode de Connexion USB**

Quand vous branchez le câble USB :

1. **Glissez la barre de notification** vers le bas

2. **Cherchez une notification** du type :
   - "Chargement via USB"
   - "Connexion USB"
   - "Appareil en charge via USB"

3. **Tapez sur cette notification** et sélectionnez :
   - ✅ **"Transfert de fichiers"** (MTP)
   - OU **"Transfert de fichiers / Android Auto"**
   
   ❌ NE PAS sélectionner :
   - "Chargement uniquement"
   - "Transfert de photos" (PTP)

---

### 💻 **ÉTAPE 3 : Redémarrer ADB (sur Mac)**

Ouvrez le Terminal et exécutez :

```bash
# 1. Aller dans le dossier du projet
cd /Users/mac/Desktop/recettes/recettes_app

# 2. Ajouter ADB au PATH
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# 3. Redémarrer ADB
adb kill-server
adb start-server

# 4. Vérifier les appareils
adb devices
```

**Résultat attendu** :
```
List of devices attached
[ID_APPAREIL]    device
```

---

### 📱 **ÉTAPE 4 : Autoriser l'Ordinateur**

Après avoir branché le téléphone, une popup devrait apparaître :

```
┌──────────────────────────────────┐
│ Autoriser le débogage USB ?      │
│                                  │
│ L'empreinte RSA de cet           │
│ ordinateur est :                 │
│ XX:XX:XX:...                     │
│                                  │
│ ☑ Toujours autoriser depuis      │
│   cet ordinateur                 │
│                                  │
│  [ANNULER]       [OK]            │
└──────────────────────────────────┘
```

**Actions** :
1. ✅ **Cochez** "Toujours autoriser depuis cet ordinateur"
2. ✅ **Tapez** sur "OK"

---

### 🔄 **ÉTAPE 5 : Débrancher/Rebrancher**

1. **Débranchez** complètement le câble USB
2. **Attendez** 5 secondes
3. **Rebranchez** le câble
4. **Attendez** la popup d'autorisation
5. **Vérifiez** à nouveau :

```bash
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
adb devices
```

---

### 🔧 **ÉTAPE 6 : Vérifier le Câble USB**

⚠️ **Important** : Tous les câbles USB ne fonctionnent pas pour le débogage !

**Tester** :
1. Essayez un **autre câble USB**
2. Le câble doit supporter le **transfert de données** (pas seulement la charge)
3. Utilisez de préférence le **câble d'origine** du téléphone

**Vérification** :
- Si le téléphone **ne charge pas** → câble défectueux
- Si le Mac **ne détecte pas** le téléphone dans Finder → câble "charge uniquement"

---

### 🖥️ **ÉTAPE 7 : Révoquer les Autorisations USB**

Si le problème persiste, réinitialisez les autorisations :

**Sur le téléphone** :
1. Paramètres → Options pour les développeurs
2. Cherchez "**Révoquer les autorisations de débogage USB**"
3. Tapez dessus
4. **Débranchez et rebranchez** le câble
5. **Autorisez** à nouveau quand la popup apparaît

---

### 🔄 **ÉTAPE 8 : Redémarrer les Appareils**

1. **Redémarrez votre téléphone Android**
2. **Attendez** qu'il démarre complètement
3. **Rebranchez** le câble USB
4. **Vérifiez** :

```bash
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
adb devices
```

---

### 🛠️ **ÉTAPE 9 : Commandes de Diagnostic**

Exécutez ces commandes pour plus d'informations :

```bash
# Voir la version d'ADB
adb version

# Lister les appareils avec détails
adb devices -l

# Redémarrer en mode root (si appareil rooté)
adb root

# Vérifier les logs
adb logcat -d | grep -i "usb"
```

---

### 📲 **ÉTAPE 10 : Utiliser un Émulateur (Alternative)**

Si le téléphone physique ne fonctionne toujours pas :

```bash
# 1. Lister les émulateurs disponibles
flutter emulators

# 2. Créer un émulateur dans Android Studio
# Ouvrir Android Studio → AVD Manager → Create Virtual Device

# 3. Lancer l'émulateur
flutter emulators --launch [NOM_EMULATEUR]

# 4. Vérifier qu'il est détecté
flutter devices
```

---

## 🎯 Test Final

Une fois que votre appareil est détecté :

```bash
# 1. Vérifier les appareils
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"
adb devices

# Résultat attendu :
# List of devices attached
# XXXXXXXXXX    device

# 2. Vérifier avec Flutter
flutter devices

# Résultat attendu :
# Found 2 connected devices:
#   [NOM_TELEPHONE] • [ID] • android-arm64 • Android X.X
#   macOS (desktop) • macos • darwin-x64 • ...

# 3. Lancer l'application
flutter run
# OU spécifier l'appareil :
flutter run -d [ID_APPAREIL]
```

---

## ⚠️ Problèmes Spécifiques par Marque

### **Samsung**
- Activez "**Mode développeur Samsung**" en plus du débogage USB
- Paramètres → Options développeur → Mode développeur Samsung : ON

### **Xiaomi / Redmi / POCO**
- Activez "**Installation via USB (Paramètres de sécurité)**"
- Paramètres → Paramètres supplémentaires → Options pour développeurs
- Activez aussi "**Autorisation USB (vérification de sécurité)**"

### **Huawei / Honor**
- Connectez-vous avec un **compte Huawei**
- Activez "**Autoriser le débogage HDB**" en plus de ADB

### **Oppo / Realme / OnePlus**
- Activez "**Débogage USB (Paramètres de sécurité)**"
- Désactivez "**Optimisation de la charge**" si présent

### **Vivo**
- Connectez-vous avec un **compte Vivo**
- Activez "**Mode développeur USB**"

---

## 📊 Checklist Complète

Avant de contacter le support, vérifiez :

- [ ] Mode développeur activé (7 taps sur numéro de build)
- [ ] Débogage USB activé dans Options développeur
- [ ] Mode USB = "Transfert de fichiers" (pas "Charge uniquement")
- [ ] Popup d'autorisation USB acceptée sur le téléphone
- [ ] "Toujours autoriser" coché sur la popup
- [ ] Câble USB testé (supporte transfert de données)
- [ ] Téléphone visible dans Finder (Mac) ou Explorateur (Windows)
- [ ] ADB server redémarré (kill-server + start-server)
- [ ] Téléphone débranché/rebranché
- [ ] Téléphone et ordinateur redémarrés
- [ ] PATH d'ADB ajouté à l'environnement

---

## 🆘 Si Rien Ne Fonctionne

1. **Utilisez un émulateur Android** (plus fiable pour le développement)
2. **Testez sur un autre téléphone Android**
3. **Vérifiez les pilotes USB** (sur Windows)
4. **Contactez le support de votre marque de téléphone**

---

## 🎉 Une Fois Résolu

Ajoutez ADB au PATH permanent :

```bash
# Ouvrir/créer .zshrc
nano ~/.zshrc

# Ajouter cette ligne à la fin :
export PATH="$PATH:$HOME/Library/Android/sdk/platform-tools"

# Sauvegarder (Ctrl+O, Enter, Ctrl+X)

# Recharger
source ~/.zshrc
```

Maintenant `adb devices` fonctionnera toujours ! ✅

---

**Bonne chance ! 🚀**

