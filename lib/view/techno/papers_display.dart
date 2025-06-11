import 'dart:convert';
import 'package:amazon_clone/model/techno_paper_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

class TechnothlonScreen extends StatefulWidget {
  static const routeName = '/technothlon-screen';

  const TechnothlonScreen({super.key});

  @override
  State<TechnothlonScreen> createState() => _TechnothlonScreenState();
}

class _TechnothlonScreenState extends State<TechnothlonScreen> {
  late Future<List<TechnoPaperModel>> papersFuture;
  final Map<String, bool> expandedMap = {};

  @override
  void initState() {
    super.initState();
    papersFuture = _loadPapers();
  }

  Future<List<TechnoPaperModel>> _loadPapers() async {
    final jsonStr = await rootBundle.loadString('assets/techno_pyqs.json');
    final jsonList = json.decode(jsonStr) as List;
    return jsonList.map((e) => TechnoPaperModel.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text(
          "Technothlon PYQs",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<List<TechnoPaperModel>>(
        future: papersFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!;
          final years = data.map((e) => e.year).toSet().toList()
            ..sort((a, b) => b.compareTo(a));
          for (var y in years) {
            expandedMap.putIfAbsent(y, () => false);
          }
          SizedBox(height: 8);
          return ListView(
            children: years.map((year) {
              final filtered = data.where((e) => e.year == year).toList();

              final Map<String, Map<String, TechnoPaperModel?>> matrix = {
                'English': {'Hauts': null, 'Juniors': null},
                'Hindi': {'Hauts': null, 'Juniors': null},
                'Answer Key': {'Hauts': null, 'Juniors': null},
              };

              for (TechnoPaperModel item in filtered) {
                if (item.category == 'Answer Key') {
                  matrix['Answer Key']?[item.squad] = item;
                } else {
                  matrix[item.language]?[item.squad] = item;
                }
              }

              final List<TableRow> rows = [];
              if (_hasContent(matrix['English']))
                rows.add(_buildRow("English", matrix['English']));
              if (_hasContent(matrix['Hindi']))
                rows.add(_buildRow("Hindi", matrix['Hindi']));
              if (_hasContent(matrix['Answer Key']))
                rows.add(_buildRow("Answer Key", matrix['Answer Key']));

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ExpansionTile(
                  initiallyExpanded: expandedMap[year]!,
                  title: Text(
                    "Technothlon $year",
                    style: TextStyle(
                      color:
                          expandedMap[year]! ? Colors.green[600] : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onExpansionChanged: (val) {
                    setState(() {
                      expandedMap[year] = val;
                    });
                  },
                  children: [
                    if (rows.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(3),
                            1: FlexColumnWidth(2),
                            2: FlexColumnWidth(2),
                          },
                          children: rows,
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          "No papers available for this year.",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  bool _hasContent(Map<String, TechnoPaperModel?>? row) {
    if (row == null) return false;
    return row.values.any(
        (paper) => paper != null && paper.url != null && paper.url != "NA");
  }

  TableRow _buildRow(String title, Map<String, TechnoPaperModel?>? row) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        _buildCell(row?['Hauts']),
        _buildCell(row?['Juniors']),
      ],
    );
  }

  Widget _buildCell(TechnoPaperModel? paper) {
    if (paper == null || paper.url == null || paper.url == "NA") {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("-"),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(paper.url!);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          paper.squad,
          style: TextStyle(
            color: Colors.green[900],
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
