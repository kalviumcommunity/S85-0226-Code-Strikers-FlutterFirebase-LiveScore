import 'package:flutter/material.dart';

class GlowBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const GlowBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF0F172A)],
        ),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(Icons.home, "HOME", 0),
          _item(Icons.group, "TEAMS", 1),

          /// ✅ CENTER + ICON ONLY
          _centerButton(),

          _item(Icons.emoji_events, "EVENTS", 3),
          _item(Icons.person, "PROFILE", 4),
        ],
      ),
    );
  }

  Widget _centerButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(.6),
              blurRadius: 14,
              spreadRadius: 1,
            )
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final active = index == i;

    return GestureDetector(
      onTap: () => onTap(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? Colors.white : Colors.white38),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: active ? Colors.white : Colors.white38,
            ),
          )
        ],
      ),
    );
  }
}