# Fiche Technique : Développeur Flutter - Projet Found-Food

Voici un résumé technique structuré de vos contributions sur l'application **Found-Food**, optimisé pour être intégré à un CV ou un portfolio.

## 🚀 Présentation du Projet
**Found-Food** est une plateforme sociale de découverte gastronomique permettant le partage d'expériences culinaires avec des données enrichies (budget, trajets, avis).

## 🛠 Stack Technique
- **Framework :** Flutter (Dart) - Développement Cross-platform.
- **Backend-as-a-Service (BaaS) :** Supabase (PostgreSQL, Auth, Storage, Realtime).
- **Gestion d'État :** Provider (Architecture réactive).
- **Navigation :** GoRouter & Deep Linking.
- **Design System :** Custom Theme (Material 3), HSL based palettes.

## 🏗 Architecture & Design Patterns
- **Clean Architecture :** Séparation stricte des couches (Data, Domain, Presentation) pour assurer la testabilité et la maintenance.
- **Repository Pattern :** Abstraction de l'accès aux données Supabase pour découpler la logique métier du backend.
- **Global Navigation Provider :** Centralisation de la gestion des états de navigation pour une expérience utilisateur fluide.

## 💡 Réalisations Techniques Clés

### 1. Système de Notifications Intelligent
- Mise en place d'un flux de notifications interactif (Suivis, Likes, Commentaires).
- **Optimisation UI :** Suppression de la pollution visuelle (diviseurs) pour un design moderne.
- **Deep Linking Interne :** Navigation contextuelle vers les profils publics ou les détails des posts directement depuis les notifications.
- **Enrichissement de données :** Affichage en temps réel du contenu des commentaires via des jointures SQL optimisées.

### 2. Expérience Utilisateur (UX) & Navigation
- **Navigation Contextuelle :** Implémentation d'un accès rapide à la recherche depuis n'importe quel point du fil d'actualité.
- **Refactoring PlaceDetails :** Optimisation du chargement des données par ID de post, permettant d'accéder aux détails d'un lieu depuis n'importe quel module de l'application sans surcharge mémoire.

### 3. Fonctionnalités Sociales & Médias
- **Fils d'actualités dynamiques :** Intégration de stories et de flux de posts avec gestion persistante des likes et favoris.
- **Gestion de Profils :** Système de statistiques utilisateur (Followers/Following) et tracking des visites de profil.
- **Gestion de Médias :** Upload et récupération optimisée de photos via Supabase Storage.

## 🔧 Problématiques Résolues
- **Gestion de la Nullité (Null Safety) :** Sécurisation du flux de données sur les écrans de détails pour éviter les crashs lors du chargement asynchrone.
- **Optimisation des Requêtes :** Réduction du nombre d'appels API en centralisant les états de navigation globaux.
- **Maintenance du Code :** Correction systématique d'erreurs de compilation et dettes techniques lors des phases de montée en version de Supabase.

---
*Ce document sert de base pour démontrer votre capacité à gérer un projet Flutter complet, de l'architecture backend à l'interface utilisateur raffinée.*
