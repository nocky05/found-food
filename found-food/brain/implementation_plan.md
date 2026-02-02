# Plan d'implémentation : Amélioration de la page de Notifications

Ce plan décrit les modifications pour retirer les traits horizontaux, ajouter la navigation vers les profils/posts et afficher le contenu des commentaires.

## Changements proposés

### Social / Data
#### [MODIFY] [notification_repository.dart](file:///c:/Users/G S T/Downloads/found-food/found-food/lib/features/social/data/repositories/notification_repository.dart)
- Tenter d'ajouter la récupération du contenu du commentaire via une jointure (si possible) ou s'assurer que toutes les métadonnées nécessaires sont récupérées.

### Social / Presentation
#### [MODIFY] [notifications_screen.dart](file:///c:/Users/G S T/Downloads/found-food/found-food/lib/features/social/presentation/screens/notifications_screen.dart)
- Remplacer `ListView.separated` par `ListView.builder` pour supprimer les traits horizontaux.
- Mettre à jour `onTap` :
    - Si type == 'follow' -> Naviguer vers `PublicProfileScreen`.
    - Si type == 'like' ou 'comment' -> Naviguer vers `PlaceDetailsScreen`.
- Afficher le contenu du commentaire sous le texte de l'action si disponible.

## Plan de vérification

### Tests Manuels
1. Ouvrir l'onglet notifications.
2. Vérifier l'absence de traits horizontaux.
3. Cliquer sur une notification de suivi -> Vérifier la navigation vers le profil.
4. Cliquer sur une notification de j'aime/commentaire -> Vérifier la navigation vers les détails du post.
5. Vérifier que le texte du commentaire est visible pour les notifications de type commentaire.
