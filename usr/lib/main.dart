import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elite Single-Match Analyst Bot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: const Color(0xFF1a1a1a),
        cardColor: const Color(0xFF2c2c2c),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2c2c2c),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ),
      home: const AnalysisPage(),
    );
  }
}

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  final _homeController = TextEditingController();
  final _awayController = TextEditingController();
  final _leagueController = TextEditingController();
  final _koTimeController = TextEditingController();

  bool _isAnalyzing = false;
  bool _analysisComplete = false;
  Map<String, dynamic>? _result;

  void _runAnalysis() {
    final home = _homeController.text;
    final away = _awayController.text;
    final league = _leagueController.text;
    final koTime = _koTimeController.text;

    if (home.isEmpty || away.isEmpty || league.isEmpty || koTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all match details.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisComplete = false;
      _result = null;
    });

    Future.delayed(const Duration(seconds: 4), () {
      // Simulate a decision on whether to recommend a bet or not
      final hasActionableBet = (home.hashCode + away.hashCode) % 2 == 0;

      if (hasActionableBet) {
        _result = {
          'showBet': true,
          'betType': 'Asian Handicap',
          'exactLine': '$home -0.75',
          'bestOdds': '1.98',
          'stake': '8',
          'confidence': '82',
          'edge': '6.1%',
          'rationale':
              'Dominant home xG creation clashes with $away’s poor defensive road record. Sharp money is backing the home side to cover the spread comfortably.',
        };
      } else {
        _result = {
          'showBet': false,
          'reason': 'Edge below threshold (4.8%) for $home vs $away match.',
        };
      }

      setState(() {
        _isAnalyzing = false;
        _analysisComplete = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elite Single-Match Analyst Bot v2.0 🎯'),
        backgroundColor: const Color(0xFF2c2c2c),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInputField(controller: _homeController, label: 'Home Team'),
            const SizedBox(height: 16),
            _buildInputField(controller: _awayController, label: 'Away Team'),
            const SizedBox(height: 16),
            _buildInputField(controller: _leagueController, label: 'League / Competition'),
            const SizedBox(height: 16),
            _buildInputField(controller: _koTimeController, label: 'Kickoff Time (UTC)'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isAnalyzing ? null : _runAnalysis,
              child: const Text('⚡ ACTIVATE ANALYSIS PROTOCOL ⚡'),
            ),
            const SizedBox(height: 32),
            _buildResultWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }

  Widget _buildResultWidget() {
    if (_isAnalyzing) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.cyanAccent),
            SizedBox(height: 16),
            Text(
              'Conducting surgical-precision analysis...',
              style: TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (!_analysisComplete || _result == null) {
      return const SizedBox.shrink();
    }

    if (_result!['showBet'] == true) {
      return _buildBetTable();
    } else {
      return _buildNoActionWidget();
    }
  }

  Widget _buildNoActionWidget() {
    return Card(
      color: Colors.red.shade900.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '🚫 NO ACTION - ${_result!['reason']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBetTable() {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            dataTextStyle: textTheme.bodyMedium,
            headingTextStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.cyanAccent),
            columns: const [
              DataColumn(label: Text('BET TYPE')),
              DataColumn(label: Text('EXACT LINE')),
              DataColumn(label: Text('BEST ODDS')),
              DataColumn(label: Text('STAKE (1-10)')),
              DataColumn(label: Text('CONFIDENCE')),
              DataColumn(label: Text('EDGE %')),
              DataColumn(label: Text('TACTICAL RATIONALE')),
            ],
            rows: [
              DataRow(cells: [
                DataCell(Text(_result!['betType'])),
                DataCell(Text(_result!['exactLine'])),
                DataCell(Text(_result!['bestOdds'])),
                DataCell(Text(_result!['stake'])),
                DataCell(Text('${_result!['confidence']}/100')),
                DataCell(Text(_result!['edge'])),
                DataCell(
                  SizedBox(
                    width: 250, // Constrain width for the rationale
                    child: Text(
                      _result!['rationale'],
                      softWrap: true,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
