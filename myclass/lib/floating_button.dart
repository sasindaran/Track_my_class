import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  FloatingButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: 'Add',
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.add,
        color: Color.fromARGB(255, 150, 235, 153),
      ),
    );
  }
}
