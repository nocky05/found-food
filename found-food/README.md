#  Found-Food

Une application mobile de partage d'expériences gastronomiques et de découverte de lieux (restaurants, parcs, plages, etc.) avec informations de trajet et fonctionnalités sociales.

##  À Propos

**Found-Food** est une application sociale qui permet aux utilisateurs de :
- Découvrir des lieux selon leur budget et proximité
-  Partager leurs expériences avec photos et vidéos
-  Interagir via likes, commentaires et statuts
-  Obtenir des informations de trajet détaillées
-  Suivre d'autres utilisateurs et voir qui visite leur profil

##  Fonctionnalités Principales

### Pour les Utilisateurs
- ✅ Connexion/Inscription avec Supabase Auth
- ✅ Enregistrer des lieux visités (restaurants, parcs, plages, piscines, îles, espaces publics)
- ✅ Poster des photos et vidéos courtes (max 1 minute)
- ✅ Liker et commenter les posts
- ✅ Publier des statuts (24h)
- ✅ Rechercher lieux par budget/proximité/type
- ✅ Système de suivis (followers/following)
- ✅ Voir qui a visité son profil
- ✅ Compteur de vues sur posts
- ✅ Informations de trajet (description, coût, durée)

### Ce que l'App NE FAIT PAS
- ❌ Vente/Livraison de nourriture
- ❌ Commandes en ligne
- ❌ Paiement

## Architecture

Le projet suit une **Clean Architecture** avec séparation des responsabilités :

```
lib/
├── core/                 # Configuration, thème, utilitaires
├── features/             # Fonctionnalités (auth, feed, places, etc.)
│   └── [feature]/
│       ├── data/         # Models, datasources, repositories
│       ├── domain/       # Entities, usecases
│       └── presentation/ # Screens, widgets, providers
└── shared/               # Widgets et modèles partagés
```

##  Design System

### Palette de Couleurs
- **Primary:** Coral Red (`#FF6B6B`) - Passion, énergie
- **Secondary:** Golden Yellow (`#FFD93D`) - Joie, optimisme
- **Accent:** Mint Green (`#6BCF7F`) - Fraîcheur

### Typographie
- **Primary Font:** Inter (headings, body)
- **Secondary Font:** Outfit (accents)

### Spacing
Système basé sur une grille de 8pt (4, 8, 16, 24, 32, 48, 64px)

##  Stack Technique

### Frontend
- **Framework:** Flutter 3.2+
- **State Management:** Provider
- **Navigation:** GoRouter
- **UI:** Material Design 3

### Backend
- **BaaS:** Supabase
- **Database:** PostgreSQL avec PostGIS
- **Auth:** Supabase Auth (Email, Google, Apple)
- **Storage:** Supabase Storage
- **Realtime:** Supabase Realtime

### Packages Principaux
```yaml
dependencies:
  supabase_flutter: ^2.5.0        # Backend
  provider: ^6.1.1                # State management
  go_router: ^13.0.0              # Navigation
  geolocator: ^10.1.0             # Géolocalisation
  google_maps_flutter: ^2.5.0     # Cartes
  image_picker: ^1.0.7            # Médias
  video_player: ^2.8.2            # Vidéos
  cached_network_image: ^3.3.1    # Images
  shimmer: ^3.0.0                 # Loading states
  lottie: ^2.7.0                  # Animations
```

##  Installation

### Prérequis
- Flutter SDK 3.2.0 ou supérieur
- Dart SDK 3.0.0 ou supérieur
- Un compte Supabase (gratuit)

### Étapes

1. **Cloner le projet**
```bash
git clone https://github.com/votre-username/found-food.git
cd found-food
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Supabase**
- Créer un projet sur [supabase.com](https://supabase.com)
- Copier l'URL et la clé anonyme
- Mettre à jour `lib/core/config/env_config.dart` :
```dart
static const String supabaseUrl = 'VOTRE_SUPABASE_URL';
static const String supabaseAnonKey = 'VOTRE_SUPABASE_ANON_KEY';
```

4. **Créer la base de données**
- Exécuter les migrations dans `supabase/migrations/`
- Configurer Row Level Security (RLS)
- Créer les buckets de storage

5. **Lancer l'application**
```bash
flutter run
```

## Structure du Projet

```
found-food/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── core/
│   │   ├── config/                  # Configuration Supabase, router
│   │   ├── constants/               # Constantes app
│   │   ├── theme/                   # Design system
│   │   └── utils/                   # Validateurs, helpers
│   ├── features/
│   │   ├── auth/                    # Authentification
│   │   ├── onboarding/              # Onboarding
│   │   ├── feed/                    # Feed principal
│   │   ├── places/                  # Gestion des lieux
│   │   ├── posts/                   # Création de posts
│   │   ├── profile/                 # Profil utilisateur
│   │   ├── search/                  # Recherche
│   │   ├── social/                  # Followers, visiteurs
│   │   └── map/                     # Carte interactive
│   └── shared/
│       └── widgets/                 # Composants réutilisables
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
├── supabase/
│   ├── migrations/                  # Schéma DB
│   └── functions/                   # Edge Functions
└── test/
```

##  Schéma de Base de Données

### Tables Principales
- `profiles` - Profils utilisateurs
- `places` - Lieux (restaurants, parcs, etc.)
- `posts` - Posts avec médias
- `post_views` - Tracking des vues
- `likes` - Likes sur posts
- `comments` - Commentaires
- `follows` - Relations de suivi
- `profile_visits` - Visites de profil
- `statuses` - Statuts 24h
- `status_views` - Vues sur statuts

##  Roadmap

### Phase 1: Setup ✅
- [x] Structure du projet
- [x] Configuration Supabase
- [x] Design system

### Phase 2: UI/UX (En cours)
- [ ] Onboarding screens
- [ ] Authentication screens
- [ ] Feed avec stories
- [ ] Profile screen
- [ ] Search screen
- [ ] Place details
- [ ] Add place form
- [ ] Create post screen

### Phase 3: Backend Integration
- [ ] Setup Supabase database
- [ ] Authentication service
- [ ] Places CRUD
- [ ] Posts CRUD
- [ ] Social features
- [ ] Realtime subscriptions

### Phase 4: Testing & Optimization
- [ ] Unit tests
- [ ] Widget tests
- [ ] Performance optimization
- [ ] Error handling

### Phase 5: Deployment
- [ ] Build APK/IPA
- [ ] App store submission

##  Contribution

Les contributions sont les bienvenues ! Veuillez suivre ces étapes :

1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

##  License

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

##  Auteur

Développé avec  pour les amoureux de la gastronomie et de la découverte.

##  Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue.

---

**Note:** Ce projet est en cours de développement actif. Certaines fonctionnalités peuvent ne pas être encore implémentées.
