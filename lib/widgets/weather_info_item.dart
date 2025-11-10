import 'package:flutter/material.dart';

class WeatherInfoItem extends StatelessWidget {
  final String iconUrl;
  final String value;
  final String label;

  const WeatherInfoItem({
    super.key,
    required this.iconUrl,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(iconUrl, width: 30, height: 30),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
      ],
    );
  }
}
