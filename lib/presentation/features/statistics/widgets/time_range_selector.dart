import 'package:flutter/material.dart';
import 'package:xpressatec/presentation/features/statistics/controllers/statistics_controller.dart';

class TimeRangeSelector extends StatelessWidget {
  final TimeRange selectedRange;
  final Function(TimeRange) onChanged;

  const TimeRangeSelector({
    Key? key,
    required this.selectedRange,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<TimeRange>(
                value: selectedRange,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: TimeRange.last7Days,
                    child: Text('Últimos 7 días'),
                  ),
                  DropdownMenuItem(
                    value: TimeRange.last30Days,
                    child: Text('Últimos 30 días'),
                  ),
                  DropdownMenuItem(
                    value: TimeRange.allTime,
                    child: Text('Todo el tiempo'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}