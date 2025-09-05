import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  final double itemHeight = 80;
  final double liftHeight = 20;
  final Set<String> _shownCongrats = {};

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;
    final textTheme = Theme.of(context).textTheme;
    final background = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(title: const Text("Leaderboard")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          final users = snapshot.data!.docs
              .map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return {
                  'id': doc.id,
                  'name': data['displayName'] ?? 'Unknown',
                  'level': data['level'] ?? 0,
                  'dev': data['dev'] ?? false,
                  'color': data['color'],
                };
              })
              .where((user) => user['dev'] != true)
              .toList();

          users.sort((a, b) => b['level'].compareTo(a['level']));

          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  for (int i = 0; i < users.length; i++)
                    _buildAnimatedUser(users[i], i, textTheme, background),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedUser(
      Map<String, dynamic> user, int index, TextTheme textTheme, Color background) {
    Color color;
    try {
      final raw = user['color'];
      if (raw is String && raw.startsWith("0x")) {
        color = Color(int.parse(raw));
      } else {
        color = Colors.grey;
      }
    } catch (_) {
      color = Colors.grey;
    }

    const int maxLevel = 10;

    final int currentLevel = user['level'];
    final bool isMax = currentLevel >= maxLevel;
    final double progress = isMax ? 1.0 : (currentLevel % maxLevel) / maxLevel;
    final String levelText = isMax ? "Klaar!" : "Level $currentLevel";

    if (isMax && !_shownCongrats.contains(user['id'])) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratsPopup(user['name'], color, user['id']);
      });
    }

    return AnimatedPositioned(
      key: ValueKey(user['id']),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      top: index * itemHeight,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: itemHeight + liftHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            elevation: 0,
            color: background,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user['name'],
                          style: textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        levelText,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 20,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                      for (int i = 1; i < maxLevel; i++)
                        Align(
                          alignment: Alignment(i / (maxLevel / 2) - 1, 0),
                          child: Container(
                            width: 2,
                            height: 12,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCongratsPopup(String userName, Color color, String userId) {
    if (_shownCongrats.contains(userId)) return;
    _shownCongrats.add(userId);

    final overlay = OverlayEntry(
      builder: (context) {
        return _CongratsOverlay(userName: userName, color: color);
      },
    );
    Overlay.of(context).insert(overlay);
    Future.delayed(const Duration(seconds: 5), () {
      overlay.remove();
    });
  }
}

class _CongratsOverlay extends StatefulWidget {
  final String userName;
  final Color color;
  const _CongratsOverlay({required this.userName, required this.color});

  @override
  State<_CongratsOverlay> createState() => _CongratsOverlayState();
}

class _CongratsOverlayState extends State<_CongratsOverlay> with SingleTickerProviderStateMixin {
  double opacity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => opacity = 1.0);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      setState(() => opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 500),
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
          Center(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.userName,
                      style: textTheme.headlineLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Heeft alle levels gehaald!',
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}