import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.activeIndex,
    required this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItemData(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'الرئيسية'),
    _NavItemData(icon: Icons.apartment_outlined, activeIcon: Icons.apartment, label: 'منازل'),
    _NavItemData(icon: Icons.group_outlined, activeIcon: Icons.group, label: 'المجموعات'),
    _NavItemData(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: 'الرسائل'),
    _NavItemData(icon: Icons.person_outline, activeIcon: Icons.person, label: 'الحساب الشخصي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5ECD7),
        border: Border(top: BorderSide(color: Color(0xFFDDD0B8), width: 0.8)),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final active = i == activeIndex;
          final item = _items[i];
          return GestureDetector(
            onTap: () => onTap(i),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      active ? item.activeIcon : item.icon,
                      key: ValueKey(active),
                      size: 24,
                      color: active
                          ? const Color(0xFF3D7A8A)
                          : const Color(0xFF9A8070),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: active
                          ? const Color(0xFF3D7A8A)
                          : const Color(0xFF9A8070),
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
