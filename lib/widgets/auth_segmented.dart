import 'package:flutter/material.dart';
import '../theme/auth_theme.dart';

class AuthSegmented extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const AuthSegmented({
    super.key,
    required this.isLogin,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    final dark = AuthTheme.isDark(context);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: dark ? AuthTheme.fieldDark : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            alignment:
            isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width / 2 - 32,
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: dark ? Colors.white : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLogin,
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isLogin
                            ? Colors.black
                            : (dark
                            ? Colors.white60
                            : Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onSignup,
                  child: Center(
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !isLogin
                            ? Colors.black
                            : (dark
                            ? Colors.white60
                            : Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}