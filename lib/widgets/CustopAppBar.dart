import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0x72d8d8d8),
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Image(
              image: AssetImage('images/microAmooz.png'),
              height: 35,
            ),
          ),
          Image(
            image: AssetImage(
              'images/gem.png',
            ),
            height: 20,
          ),
          Image(
            image: AssetImage(
              'images/coin.png',
            ),
            height: 20,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
