import 'package:flutter/material.dart';
import 'package:dailyme/utils/storage/util_hive.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<Map<int, Map<int, List<Map<String, dynamic>>>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _fetchStats();
  }

  Future<Map<int, Map<int, List<Map<String, dynamic>>>>> _fetchStats() async {
    final now = DateTime.now();
    final Map<int, Map<int, List<Map<String, dynamic>>>> data = {};
    for (int year = 2020; year <= now.year; year++) {
      final yearEntries = await HiveDayStorage.retrieveYear(year);
      for (final entry in yearEntries) {
        final date = DateTime.tryParse(entry['date'] ?? '');
        if (date == null) continue;
        data.putIfAbsent(year, () => {});
        data[year]!.putIfAbsent(date.month, () => []);
        data[year]![date.month]!.add(entry);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: FutureBuilder<Map<int, Map<int, List<Map<String, dynamic>>>>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          if (data.isEmpty) {
            return const Center(child: Text('No data available.'));
          }
          final years = data.keys.toList()..sort((a, b) => b.compareTo(a));
          final List<Widget> monthCards = [];
          for (final year in years) {
            final months = data[year]!.keys.toList()..sort();
            // Add a year label before the first month of each year
            monthCards.add(Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text('$year', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ));
            for (final month in months) {
              final entries = data[year]![month]!;
              final entryCount = entries.length;
              final daysWithEntry = entries.map((e) => e['date']).toSet().length;
              final maxDays = DateUtils.getDaysInMonth(year, month);
              // Count types
              int onlyRating = 0, onlyNote = 0, both = 0;
              final ratings = <int>[];
              for (final e in entries) {
                final note = (e['note'] ?? '').toString().trim();
                final rating = e['rating'] is int ? e['rating'] : int.tryParse(e['rating']?.toString() ?? '');
                final hasNote = note.isNotEmpty;
                final hasRating = rating != null;
                if (hasNote && hasRating) {
                  both++;
                } else if (hasNote) onlyNote++;
                else if (hasRating) onlyRating++;
                if (hasRating) ratings.add(rating!);
              }
              final double? avg = ratings.isNotEmpty ? ratings.reduce((a, b) => a + b) / ratings.length : null;
              final int? minRating = ratings.isNotEmpty ? ratings.reduce((a, b) => a < b ? a : b) : null;
              final int? maxRating = ratings.isNotEmpty ? ratings.reduce((a, b) => a > b ? a : b) : null;
              final int? diffRating = (minRating != null && maxRating != null) ? (maxRating - minRating) : null;
              monthCards.add(Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black.withOpacity(0.7), width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM').format(DateTime(year, month)),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Days with entry: $daysWithEntry / $maxDays'),
                          Text('Entries: $entryCount'),
                          Text('Only rating: $onlyRating, Only note: $onlyNote, Both: $both'),
                          if (avg != null)
                            Row(
                              children: [
                                const Text('Average rating: '),
                                Text(
                                  avg.toStringAsFixed(2),
                                  style: TextStyle(
                                    color: avg >= 4
                                        ? Colors.green[700]
                                        : avg >= 2
                                            ? Colors.orange[700]
                                            : Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          if (minRating != null && maxRating != null) ...[
                            Row(
                              children: [
                                const Text('Min rating: '),
                                Text('$minRating', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                const Text('Max rating: '),
                                Text('$maxRating', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Difference: '),
                                Text('$diffRating', style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ));
            }
          }
          return ListView(
            children: monthCards,
          );
        },
      ),
    );
  }
}
