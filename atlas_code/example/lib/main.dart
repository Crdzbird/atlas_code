import 'dart:async';

import 'package:atlas_code/atlas_code.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _atlas = AtlasCode();
  LocalizedCountryNames? _names;
  String _query = '';
  StreamSubscription<Locale>? _localeSubscription;

  @override
  void initState() {
    super.initState();
    unawaited(_loadNames());
    // Refresh names when the user changes the system language/region.
    _localeSubscription =
        _atlas.deviceLocaleChanges.listen((_) => unawaited(_loadNames()));
  }

  @override
  void dispose() {
    unawaited(_localeSubscription?.cancel());
    super.dispose();
  }

  Future<void> _loadNames() async {
    final names = await _atlas.localizedNames();
    if (!mounted) return;
    setState(() => _names = names);
  }

  @override
  Widget build(BuildContext context) {
    final device = Countries.current;
    final names = _names;
    final countries = names == null
        ? Countries.all.where((c) => c.matches(_query)).toList()
        : names.search(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('atlas_code example')),
      body: Column(
        children: [
          if (device != null)
            ListTile(
              leading: Text(
                device.flagEmoji,
                style: const TextStyle(fontSize: 28),
              ),
              title: Text('Device country: ${device.name}'),
              subtitle: Text(
                '${device.alpha2} · ${device.alpha3} · '
                '${device.dialCode ?? 'no dial code'} · '
                '${device.currencyCodes.join(', ')}',
              ),
            ),
          if (names != null && names.isFallback)
            const ListTile(
              dense: true,
              leading: Icon(Icons.info_outline),
              title: Text(
                'OS localization unavailable — showing English names',
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search name, code or dial code',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: countries.length,
              itemBuilder: (context, index) {
                final country = countries[index];
                return ListTile(
                  leading: Text(
                    // Windows has no flag emoji font — fall back to the code.
                    Countries.flagEmojiSupported
                        ? country.flagEmoji
                        : country.alpha2,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(names?.of(country) ?? country.name),
                  subtitle: Text(
                    [
                      country.alpha2,
                      country.dialCode ?? '—',
                      ...country.capitals.take(1),
                    ].join(' · '),
                  ),
                  trailing: Text(
                    country.currencies.map((c) => c.symbol).join(' '),
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
