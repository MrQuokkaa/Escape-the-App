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

          // Map Firestore docs to local list
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

          // Sort descending by level
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

  Widget _buildAnimatedUser(Map<String, dynamic> user, int index,
      TextTheme textTheme, Color background) {
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
        height: itemHeight + liftHeight, // Lift height when moving
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Material(
            elevation: 0,
            color: background,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(user['name'], style: textTheme.bodyLarge),
                  ),
                  SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      value: (user['level'] % 10) / 10,
                      minHeight: 20,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text("Level ${user['level']}", style: textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
