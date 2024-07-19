import 'package:flutter/material.dart';
import 'package:event_planning/models/EventCategory.dart';

class CategoryCard extends StatelessWidget {
  final EventCategory category;
  final VoidCallback onTap;

  const CategoryCard({Key? key, required this.category, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: category.isSelected ? Colors.green[100] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: category.isSelected
                // ignore: prefer_const_constructors
                ? Color.fromARGB(255, 56, 96, 35)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(8),
                child: _buildCategoryVisual(),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
              width: double.infinity,
              child: Text(
                category.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: category.isSelected ? Colors.green[800] : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryVisual() {
    if (category.imagePath != null) {
      return Image.asset(
        category.imagePath!,
        fit: BoxFit.contain,
      );
    } else if (category.icon != null) {
      return Icon(
        category.icon,
        size: 40,
        color: category.isSelected
            ? const Color.fromARGB(255, 46, 125, 68)
            : Color.fromARGB(255, 76, 151, 115),
      );
    } else {
      return SizedBox();
    }
  }
}
