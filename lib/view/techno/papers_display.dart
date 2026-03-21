import 'dart:convert';
import 'package:techniche26/model/techno_paper_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FutureBuilder<List<TechnoPaperModel>>(
              future: papersFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF002B5B)));
                }

                final data = snapshot.data!;
                final years = data.map((e) => e.year).toSet().toList()
                  ..sort((a, b) => b.compareTo(a));
                for (var y in years) {
                  expandedMap.putIfAbsent(y, () => false);
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                  itemCount: years.length,
                  itemBuilder: (context, index) {
                    final year = years[index];
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
                    if (_hasContent(matrix['English'])) {
                      rows.add(_buildRow("English", matrix['English']));
                    }
                    if (_hasContent(matrix['Hindi'])) {
                      rows.add(_buildRow("Hindi", matrix['Hindi']));
                    }
                    if (_hasContent(matrix['Answer Key'])) {
                      rows.add(_buildRow("Answer Key", matrix['Answer Key']));
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          onExpansionChanged: (expanded) {
                            setState(() {
                              expandedMap[year] = expanded;
                            });
                          },
                          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          title: Text(
                            "Technothlon $year",
                            style: const TextStyle(
                              color: Color(0XFF232930),
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              fontFamily: 'Univers',
                              height: 1.2,
                            ),
                          ),
                          iconColor: const Color(0xFF6D7985),
                          collapsedIconColor: const Color(0xFF6D7985),
                          children: [
                            if (rows.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                                child: Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2),
                                    2: FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        const SizedBox(),
                                        _buildHeaderCell("Hauts"),
                                        _buildHeaderCell("Juniors"),
                                      ],
                                    ),
                                    ...rows,
                                  ],
                                ),
                              )
                            else
                              const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  "No papers available for this year.",
                                  style: TextStyle(
                                      color: Color(0xFF6D7985),
                                      fontFamily: 'General Sans',
                                      fontStyle: FontStyle.italic),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF002B5B),
        image: DecorationImage(
          image: AssetImage('assets/ghm/frame3.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0xFFAFAFAF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6D7985), size: 20),
                    ),
                  ),
                  const Spacer(flex: 1),
                  const Text(
                    'TECHNOTHLON PYQS',
                    style: TextStyle(
                      color: Color(0XFF232930),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Univers',
                      height: 1.2,
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF6D7985),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'General Sans',
          height: 1.2,
        ),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  color: Color(0XFF232930),
                  fontSize: 14,
                  fontFamily: 'General Sans',
                  height: 1.2)),
        ),
        _buildCell(row?['Hauts']),
        _buildCell(row?['Juniors']),
      ],
    );
  }

  Widget _buildCell(TechnoPaperModel? paper) {
    if (paper == null || paper.url == null || paper.url == "NA") {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text("-", style: TextStyle(color: Color(0xFFBDBDBD))),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () async {
            final uri = Uri.parse(paper.url!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE1EBFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.file_download_outlined,
              color: Color(0xFF002B5B),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
