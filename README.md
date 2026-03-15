# 🎬 MovieMG — App de streaming Flutter

Application de streaming de films et séries utilisant TMDB + Vidsrc + AdMob.

---

## 🚀 Installation

### 1. Prérequis
- Flutter SDK installé (https://flutter.dev)
- Android Studio ou VS Code
- Compte TMDB (gratuit)
- Compte Google AdMob

### 2. Clé API TMDB
1. Va sur https://www.themoviedb.org
2. Crée un compte gratuit
3. Va dans Paramètres → API → Créer une clé API
4. Copie ta clé API
5. Remplace `TON_API_KEY_TMDB_ICI` dans `lib/services/tmdb_service.dart`

### 3. Configuration AdMob
1. Va sur https://admob.google.com
2. Crée ton app
3. Récupère tes IDs d'unités publicitaires
4. Remplace les IDs de test dans `lib/services/admob_service.dart`
5. Configure aussi `AndroidManifest.xml` avec ton App ID AdMob :
   ```xml
   <meta-data
     android:name="com.google.android.gms.ads.APPLICATION_ID"
     android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
   ```

### 4. Lancer le projet
```bash
flutter pub get
flutter run
```

---

## 📱 Fonctionnalités

- ✅ Films et séries tendances
- ✅ Films en cours de diffusion
- ✅ Séries populaires
- ✅ Recherche par titre
- ✅ Lecteur vidéo Vidsrc (plein écran)
- ✅ Monétisation AdMob (bannière + interstitiel)
- ✅ Interface dark mode premium

---

## 🏗️ Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── models/
│   └── movie.dart               # Modèles de données
├── services/
│   ├── tmdb_service.dart        # API TMDB
│   └── admob_service.dart       # Google AdMob
└── screens/
    ├── home_screen.dart         # Écran principal
    ├── detail_screen.dart       # Détail film/série
    ├── player_screen.dart       # Lecteur vidéo Vidsrc
    └── search_screen.dart       # Recherche
```

---

## 💰 Revenus estimés

| Utilisateurs | Revenus/mois |
|---|---|
| 1 000 | 5 - 20$ |
| 10 000 | 50 - 200$ |
| 100 000 | 500 - 2 000$ |
| 1 000 000 | 5 000 - 20 000$ |

---

## 📝 Prochaines améliorations

- [ ] Watchlist / Favoris (Firebase)
- [ ] Authentification utilisateur
- [ ] Téléchargement dans dossier accessible
- [ ] Notifications nouveaux films
- [ ] Support Chromecast