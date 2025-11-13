import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeeklyForecastSection extends StatelessWidget {
  final List<dynamic> next7days;

  const WeeklyForecastSection({super.key, required this.next7days});

  String formatDate(String dateStr) {
    DateTime date = DateTime.parse(dateStr);
    return DateFormat.E().add_MMMd().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: next7days.length,
      itemBuilder: (context, index) {
        final day = next7days[index];
        final condition = day['day']['condition']['text'];
        final icon = "https:${day['day']['condition']['icon']}";
        final avgTemp = day['day']['avgtemp_c'];
        final maxTemp = day['day']['maxtemp_c'];
        final minTemp = day['day']['mintemp_c'];

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          color: Theme.of(context).primaryColor,
          child: ListTile(
            leading: Image.network(icon, width: 45, height: 45),
            title: Text(
              formatDate(day['date']),
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              condition,
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$avgTemp°C",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  "$minTemp°C - $maxTemp°C",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
