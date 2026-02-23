import 'package:flutter/material.dart';

class GlowBottomNav extends StatelessWidget {
  final int index;
  final Function(int) onTap;

  const GlowBottomNav({
    super.key,
    required this.index,
    required this.onTap,
  });

  // Colors matching the Teams UI
  final Color primaryPurple = const Color(0xFF8B5CF6);
  final Color accentCyan = const Color(0xFF22D3EE);
  final Color inactiveColor = Colors.white38;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90, // Slightly taller for better spacing
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Deep Navy
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(Icons.home_filled, "HOME", 0),
              _item(Icons.groups_rounded, "TEAMS", 1),

              const SizedBox(width: 46), // Spacer for the floating center button

              _item(Icons.emoji_events_outlined, "EVENTS", 3),
              _item(Icons.person_outline, "PROFILE", 4),
            ],
          ),

          /// ✅ FLOATING CENTER BUTTON
          Positioned(
            top: 15,
            left: MediaQuery.of(context).size.width / 2 - 27,
            child: _centerButton(),
          ),
        ],
      ),
    );
  }

  Widget _centerButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryPurple, accentCyan],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(.4),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _item(IconData icon, String label, int i) {
    final active = index == i;

    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Active Indicator Line
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 8),
            height: 3,
            width: active ? 20 : 0,
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                if (active) BoxShadow(color: primaryPurple, blurRadius: 8),
              ],
            ),
          ),

          Icon(
            icon,
            color: active ? Colors.white : inactiveColor,
            size: 26,
          ),

          const SizedBox(height: 6),

          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 0.5,
              color: active ? Colors.white : inactiveColor,
            ),
          )
        ],
      ),
    );
  }
}