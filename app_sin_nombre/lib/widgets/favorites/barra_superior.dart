import 'package:flutter/material.dart';

class SuperFixAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SuperFixAppBar({super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: true,
      centerTitle: true,
      title: Text(
        "SuperFix",
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF5963),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
