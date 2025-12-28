import 'package:flutter/material.dart';
import 'package:womensafety/utils/constants.dart';

class FABBottomAppBarItem {
  FABBottomAppBarItem({required this.iconData, required this.text});
  final IconData iconData;
  final String text;
}

class FABBottomAppBar extends StatefulWidget {
  FABBottomAppBar({
    required this.items,
    this.height = 60.0,
    this.iconSize = 24.0,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    required this.onTabSelected,
  });

  final List<FABBottomAppBarItem> items;
  final double height;
  final double iconSize;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final ValueChanged<int> onTabSelected;

  @override
  _FABBottomAppBarState createState() => _FABBottomAppBarState();
}

class _FABBottomAppBarState extends State<FABBottomAppBar> {
  int _selectedIndex = 0;

  void _updateIndex(int index) {
    widget.onTabSelected(index);
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildTabItem({
      required FABBottomAppBarItem item,
      required int index,
    }) {
      final Color iconColor = _selectedIndex == index
          ? (widget.selectedColor ?? Colors.red)
          : (widget.unselectedColor ?? Colors.grey);

      return Expanded(
        child: SizedBox(
          height: widget.height,
          child: InkWell(
            onTap: () => _updateIndex(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.iconData,
                    color: iconColor, size: widget.iconSize),
                const SizedBox(height: 4),
                Text(
                  item.text,
                  style: TextStyle(color: iconColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BottomAppBar(
      elevation: 8,
      color: widget.backgroundColor ?? Colors.white, // ✅ FIXED
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.items.length,
              (index) => _buildTabItem(
            item: widget.items[index],
            index: index,
          ),
        ),
      ),
    );
  }
}
