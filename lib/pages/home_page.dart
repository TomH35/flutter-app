import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_data_provider.dart';
import '../settings_page.dart';
import '../utils/helper_functions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // init() sa zavolá iba raz, až po vykreslení prvého snímku –
    // notifyListeners() a EasyLoading.show() sa nesmú volať počas build-u.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AppDataProvider>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earthquake App'),
        actions: [
          IconButton(
            tooltip: 'Sort',
            onPressed: _showSortingDialog,
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Consumer<AppDataProvider>(
        builder: (context, provider, child) {
          // 1. chyba pri prvom načítaní
          if (!provider.hasDataLoaded && provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(provider.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.getEarthquakeData,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          // 2. dáta sa ešte načítavajú
          if (!provider.hasDataLoaded) {
            return const Center(child: Text('Please wait...'));
          }

          final earthquakes = provider.earthquakes;

          return Column(
            children: [
              _InfoHeader(provider: provider, count: earthquakes.length),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: provider.getEarthquakeData,
                  child: earthquakes.isEmpty
                      // 3. žiadne záznamy (ListView kvôli pull-to-refresh)
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No records found.')),
                          ],
                        )
                      // 4. zoznam zemetrasení
                      : ListView.builder(
                          itemCount: earthquakes.length,
                          itemBuilder: (context, index) {
                            final data = earthquakes[index].properties!;
                            return ListTile(
                              title: Text(
                                data.place ?? data.title ?? 'Unknown',
                              ),
                              subtitle: Text(
                                data.time == null
                                    ? 'Unknown time'
                                    : getFormattedDateTime(
                                        data.time!,
                                        'EEE MMM dd yyyy hh:mm a',
                                      ),
                              ),
                              trailing: Chip(
                                avatar: data.alert == null
                                    ? null
                                    : CircleAvatar(
                                        backgroundColor:
                                            provider.getAlertColor(data.alert!),
                                      ),
                                label: Text(
                                  data.mag == null
                                      ? '–'
                                      : data.mag!.toStringAsFixed(1),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSortingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort by'),
        content: Consumer<AppDataProvider>(
          builder: (context, provider, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in _sortOptions)
                SortOption(
                  groupValue: provider.orderBy,
                  value: option.$1,
                  label: option.$2,
                  onChange: provider.setOrder,
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Hodnoty parametra orderby podľa dokumentácie USGS API
const _sortOptions = [
  ('magnitude', 'Magnitude - Desc'),
  ('magnitude-asc', 'Magnitude - Asc'),
  ('time', 'Time - Desc'),
  ('time-asc', 'Time - Asc'),
];

// Jedna možnosť triedenia (ikona výberu + text).
// Nevolá sa RadioGroup, aby nekolidovala s rovnomenným widgetom Flutteru.
class SortOption extends StatelessWidget {
  final String groupValue;
  final String value;
  final String label;
  final void Function(String) onChange;

  const SortOption({
    super.key,
    required this.groupValue,
    required this.value,
    required this.label,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: selected ? Theme.of(context).colorScheme.primary : null,
      ),
      title: Text(label),
      onTap: () => onChange(value),
    );
  }
}

// Riadok nad zoznamom: obdobie, filtre a počet záznamov
class _InfoHeader extends StatelessWidget {
  final AppDataProvider provider;
  final int count;

  const _InfoHeader({required this.provider, required this.count});

  @override
  Widget build(BuildContext context) {
    final location = provider.shouldUseLocation
        ? ' · within ${provider.maxRadiusKm.toInt()} km'
            '${provider.currentCity == null ? '' : ' of ${provider.currentCity}'}'
        : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Text(
        '${provider.startTime} → ${provider.endTime} · '
        'M ${provider.minMagnitude}+$location · $count records',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
