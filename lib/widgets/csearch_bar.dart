import 'package:flutter/material.dart';

class CSearchBar extends StatelessWidget {
  final Function(String) onSubmitted;

  const CSearchBar({super.key, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      width: 350,
      child: TextField(
        style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        onSubmitted: (value) {
          if (value.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter the city name')),
            );
            return;
          }
          onSubmitted(value.trim());
        },
        decoration: InputDecoration(
          labelText: "Search City",
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.surface,
          ),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.surface),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
