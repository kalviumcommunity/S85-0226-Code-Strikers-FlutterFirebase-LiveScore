import 'package:flutter/material.dart';
import '../theme/auth_theme.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool focused = false;

  @override
  Widget build(BuildContext context) {
    final dark = AuthTheme.isDark(context);

    return Focus(
      onFocusChange: (v) => setState(() => focused = v),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 56,
        decoration: BoxDecoration(
          color: dark ? AuthTheme.fieldDark : AuthTheme.fieldLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: focused
              ? [
            BoxShadow(
              color: AuthTheme.primary.withOpacity(.25),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Icon(widget.icon,
                color: focused
                    ? AuthTheme.primary
                    : (dark ? Colors.white70 : Colors.grey)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                obscureText: widget.obscure,
                style: TextStyle(
                    color: dark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: dark ? Colors.white38 : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}