import 'package:flutter/material.dart';

class AppColors {
  // ============================================
  // COULEURS EXACTES DE LA MAQUETTE
  // ============================================
  
  // Couleurs Principales (de la maquette)
  static const Color primaryOrange = Color(0xFFFF6B35);      // Orange vif (boutons, accents)
  static const Color secondaryYellow = Color(0xFFE0A800);    // Jaune doré/moutarde (bouton Call)
  static const Color lightPeach = Color(0xFFFFE5D9);         // Beige/pêche clair (badges)
  static const Color headerOrange = Color(0xFFFF6B35);       // Orange header
  static const Color headerYellow = Color(0xFFF7B731);       // Jaune header
  
  // Alias pour compatibilité
  static const Color primaryColor = primaryOrange;
  static const Color secondaryColor = secondaryYellow;
  static const Color accentColor = lightPeach;
  
  // ============================================
  // BACKGROUNDS
  // ============================================
  static const Color backgroundColor = Color(0xFFFAFAFA);    // Fond principal
  static const Color cardBackground = Color(0xFFFFFFFF);     // Fond des cards
  static const Color surfaceColor = Color(0xFFF5F5F5);       // Surface secondaire
  
  // ============================================
  // TEXTES
  // ============================================
  static const Color textPrimary = Color(0xFF2D3436);        // Texte principal (noir)
  static const Color textSecondary = Color(0xFF636E72);      // Texte secondaire (gris)
  static const Color textLight = Color(0xFF95A5A6);          // Texte clair
  static const Color textWhite = Color(0xFFFFFFFF);          // Texte blanc
  
  // ============================================
  // ACTIONS
  // ============================================
  static const Color likeColor = Color(0xFFFF6B35);          // Orange pour likes
  static const Color commentColor = Color(0xFF636E72);       // Gris pour commentaires
  static const Color shareColor = Color(0xFF636E72);         // Gris pour partage
  
  // ============================================
  // STATUTS
  // ============================================
  static const Color successColor = Color(0xFF00B894);       // Vert succès
  static const Color errorColor = Color(0xFFD63031);         // Rouge erreur
  static const Color warningColor = Color(0xFFFDCB6E);       // Jaune warning
  static const Color infoColor = Color(0xFF0984E3);          // Bleu info
  
  // ============================================
  // BORDERS & DIVIDERS
  // ============================================
  static const Color borderColor = Color(0xFFDFE6E9);        // Bordure
  static const Color dividerColor = Color(0xFFECF0F1);       // Divider
  
  // ============================================
  // GRADIENTS (de la maquette)
  // ============================================
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B35),  // Orange vif
      Color(0xFFF7B731),  // Jaune doré
    ],
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFFF6B35),  // Orange vif
      Color(0xFFFF8C42),  // Orange plus clair
    ],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
  );
  
  // Gradient pour le splash screen
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B35),  // Orange vif
      Color(0xFFF7B731),  // Jaune doré
    ],
  );
  
  // ============================================
  // SHADOWS
  // ============================================
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFFFF6B35).withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
  
  static final List<BoxShadow> storyShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  // ============================================
  // COULEURS SPÉCIFIQUES AUX COMPOSANTS
  // ============================================
  
  // Stories
  static const Color storyBorderActive = Color(0xFFFF6B35);  // Orange vif
  static const Color storyBorderInactive = Color(0xFFDFE6E9); // Gris clair
  
  // Badges
  static const Color badgeBackground = Color(0xFFFFE5D9);    // Beige/pêche
  static const Color badgeText = Color(0xFFFF6B35);          // Orange vif
  
  // Price indicators
  static const Color priceColor = Color(0xFFFF6B35);         // Orange vif
  
  // Distance badge
  static const Color distanceBadgeBackground = Color(0xFFFFE5D9); // Beige/pêche
  static const Color distanceBadgeText = Color(0xFFFF6B35);       // Orange vif
  
  // Buttons (couleurs exactes de la maquette)
  static const Color buttonDirections = Color(0xFFFF6B35);   // Orange vif
  static const Color buttonCall = Color(0xFFE0A800);         // Jaune doré/moutarde
  
  // Icons
  static const Color iconPrimary = Color(0xFF2D3436);        // Noir
  static const Color iconSecondary = Color(0xFF636E72);      // Gris
  static const Color iconActive = Color(0xFFFF6B35);         // Orange vif
  
  // Bottom Navigation
  static const Color bottomNavActive = Color(0xFFFF6B35);    // Orange vif
  static const Color bottomNavInactive = Color(0xFF95A5A6);  // Gris clair
  static const Color bottomNavBackground = Color(0xFFFFFFFF); // Blanc
}
