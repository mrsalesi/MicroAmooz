import 'package:flutter/material.dart';
import '../screens/Page05.dart';
import '../screens/Page06.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  void _handleTap(BuildContext context, int index) {
    onTap(index);

    if (index == 2) {
      // دکمه‌ی خانه: می‌ره به Page05 و همه‌ی صفحات قبلی رو از استک پاک می‌کنه
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const Page06()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: "پروفایل",
          ),
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.flash_on_outlined,
            activeIcon: Icons.flash_on,
            label: "صاعقه",
          ),
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: "خانه",
          ),
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: "هشدارها",
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;
    final Color color = isActive ? const Color(0xff1291a7) : Colors.grey;

    return InkWell(
      onTap: () => _handleTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
