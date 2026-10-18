import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_data_provider.dart';
import 'utils/helper_functions.dart';

// StatelessWidget – všetok stav je v AppDataProvider, setState sa nepoužíva.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _magnitudes = [2.5, 4.0, 5.0, 6.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) => ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            // ---------------- ČAS ----------------
            Text('Time Settings',
                style: Theme.of(context).textTheme.titleMedium),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(provider.startTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date =
                            await _selectDate(context, provider.startTime);
                        if (date != null) provider.setStartTime(date);
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(provider.endTime),
                    trailing: IconButton(
                      onPressed: () async {
                        final date =
                            await _selectDate(context, provider.endTime);
                        if (date != null) provider.setEndTime(date);
                      },
                      icon: const Icon(Icons.calendar_month),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ElevatedButton(
                      onPressed: () {
                        if (!provider.isDateRangeValid) {
                          showMessage(context,
                              'Start time must be before end time');
                          return;
                        }
                        provider.getEarthquakeData();
                        showMessage(context, 'Times are updated');
                      },
                      child: const Text('Update Time Changes'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- MAGNITÚDA ----------------
            Text('Minimum Magnitude',
                style: Theme.of(context).textTheme.titleMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  children: [
                    for (final mag in _magnitudes)
                      ChoiceChip(
                        label: Text('$mag+'),
                        selected: provider.minMagnitude == mag,
                        onSelected: (_) => provider.setMinMagnitude(mag),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---------------- POLOHA ----------------
            Text('Location Settings',
                style: Theme.of(context).textTheme.titleMedium),
            Card(
              child: SwitchListTile(
                title: Text(provider.currentCity ?? 'Your location is unknown'),
                subtitle: Text(
                  provider.shouldUseLocation
                      ? 'Showing earthquakes within '
                          '${provider.maxRadiusKm.toInt()} km'
                      : 'Turn on to show only nearby earthquakes',
                ),
                value: provider.shouldUseLocation,
                onChanged: (value) async {
                  final error = await provider.setLocation(value);
                  if (error != null && context.mounted) {
                    showMessage(context, error);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _selectDate(BuildContext context, String current) async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(current),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (dt != null) {
      return getFormattedDateTime(dt.millisecondsSinceEpoch);
    }
    return null;
  }
}
