import 'package:flutter/material.dart';
import 'package:found_food/features/stories/domain/models/story_model.dart';
import 'package:found_food/core/theme/app_colors.dart';
import 'dart:async';

class StoryViewerScreen extends StatefulWidget {
  final List<UserStories> userStoriesList;
  final int initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.userStoriesList,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late PageController _pageController;
  int _currentUserIndex = 0;
  int _currentStoryIndex = 0;
  Timer? _timer;
  double _percent = 0.0;

  @override
  void initState() {
    super.initState();
    _currentUserIndex = widget.initialUserIndex;
    _pageController = PageController(initialPage: _currentUserIndex);
    _startStoryTimer();
  }

  void _startStoryTimer() {
    _timer?.cancel();
    _percent = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_percent < 1.0) {
          _percent += 0.01;
        } else {
          _timer?.cancel();
          _nextStory();
        }
      });
    });
  }

  void _nextStory() {
    final stories = widget.userStoriesList[_currentUserIndex].stories;
    if (_currentStoryIndex < stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _startStoryTimer();
      });
    } else {
      _nextUser();
    }
  }

  void _previousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _startStoryTimer();
      });
    } else {
      _previousUser();
    }
  }

  void _nextUser() {
    if (_currentUserIndex < widget.userStoriesList.length - 1) {
      setState(() {
        _currentUserIndex++;
        _currentStoryIndex = 0;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startStoryTimer();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _previousUser() {
    if (_currentUserIndex > 0) {
      setState(() {
        _currentUserIndex--;
        _currentStoryIndex = 0;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startStoryTimer();
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserStories = widget.userStoriesList[_currentUserIndex];
    final currentStory = currentUserStories.stories[_currentStoryIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousStory();
          } else {
            _nextStory();
          }
        },
        child: Stack(
          children: [
            // Media Content
            Positioned.fill(
              child: Image.network(
                currentStory.mediaUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator(color: Colors.white));
                },
              ),
            ),

            // Top Progress Bars
            _buildProgressBar(currentUserStories.stories.length),

            // Header Info
            _buildHeader(currentUserStories),

            // Close Button
            Positioned(
              top: 50,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int count) {
    return Positioned(
      top: 40,
      left: 8,
      right: 8,
      child: Row(
        children: List.generate(count, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: LinearProgressIndicator(
                value: index == _currentStoryIndex
                    ? _percent
                    : (index < _currentStoryIndex ? 1.0 : 0.0),
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(UserStories user) {
    return Positioned(
      top: 55,
      left: 16,
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            backgroundColor: AppColors.primaryOrange,
            child: user.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
          ),
          const SizedBox(width: 10),
          Text(
            user.username,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
