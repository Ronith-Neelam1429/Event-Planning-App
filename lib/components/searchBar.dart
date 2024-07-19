import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search...',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.grey),
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
