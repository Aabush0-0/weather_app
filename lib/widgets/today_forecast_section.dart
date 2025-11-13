import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../views/weekly_screen.dart';

class TodayForecastSection extends StatelessWidget {
  final List<dynamic> hourly;
  final List<dynamic> pastWeek;
  final List<dynamic> next7days;
  final Map<String, dynamic> currentValue;
  final String city;

  const TodayForecastSection({
    super.key,
    required this.hourly,
    required this.pastWeek,
    required this.next7days,
    required this.currentValue,
    required this.city,
  });

  String formatTime(String timeString) {
    DateTime time = DateTime.parse(timeString);
    return DateFormat.j().format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.secondary),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Forecast",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Weekly(
                          currentValue: currentValue,
                          city: city,
                          pastWeek: pastWeek,
                          next7days: next7days,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Weekly Forecast",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Theme.of(context).colorScheme.secondary),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final hour = hourly[index];
                final now = DateTime.now();
                final hourTime = DateTime.parse(hour['time']);
                final isCurrentHour =
                    now.hour == hourTime.hour && now.day == hourTime.day;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    height: 70,
                    width: 80,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrentHour
                          ? Colors.orangeAccent
                          : Colors.black38,
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          isCurrentHour ? "Now" : formatTime(hour['time']),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Image.network(
                          "https:${hour['condition']?['icon']}",
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          "${hour["temp_c"]}°C",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
