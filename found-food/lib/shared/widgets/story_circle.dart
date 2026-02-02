import 'package:flutter/material.dart';

class StoryCircle extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool hasStory;
  final VoidCallback onTap;
  final bool showAddButton; // Afficher le bouton "+" pour ajouter une story
  final VoidCallback? onAddTap; // Callback pour le bouton "+"

  const StoryCircle({
    super.key,
    required this.imageUrl,
    required this.name,
    this.hasStory = true,
    required this.onTap,
    this.showAddButton = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            // Story Circle with border
            Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStory
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFF6B35), // Orange vif
                              Color(0xFFF7B731), // Jaune doré
                            ],
                          )
                        : null,
                    border: !hasStory
                        ? Border.all(
                            color: isDark ? Colors.grey[800]! : const Color(0xFFDFE6E9), 
                            width: 2
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: isDark ? Colors.grey[900] : const Color(0xFFF5F5F5),
                                  child: Icon(
                                    Icons.person,
                                    color: isDark ? Colors.white24 : const Color(0xFF95A5A6),
                                    size: 30,
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: isDark ? Colors.grey[900] : const Color(0xFFF5F5F5),
                              child: Icon(
                                Icons.person,
                                color: isDark ? Colors.white24 : const Color(0xFF95A5A6),
                                size: 30,
                              ),
                            ),
                    ),
                  ),
                ),
                // Bouton "+" pour ajouter une story
                if (showAddButton)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: onAddTap ?? () {},
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor, 
                            width: 2
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Name
            SizedBox(
              width: 70,
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
