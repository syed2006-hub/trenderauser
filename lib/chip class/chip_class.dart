
import 'package:flutter/material.dart';

class Chipclass extends StatelessWidget { 
  final String filterforchip;
  final String currentfiltertextforchip;

  const Chipclass({
    super.key, 
    required this.filterforchip,
    required this.currentfiltertextforchip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Chip(
          
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
          label: Image.asset(filterforchip, height: 35, width: 35),
          backgroundColor: Colors.white,
          side: BorderSide.none,
          
          elevation: 5,
        ),
        const SizedBox(height: 5),
        Text(currentfiltertextforchip, style: TextStyle(color: Colors.white,fontSize: 12)),
      ],
    );
  }
}
