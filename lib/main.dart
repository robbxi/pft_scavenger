import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: StartPage(),
  ));
}
AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color.fromARGB(139, 255, 219, 14), const Color.fromARGB(255, 53, 45, 24)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    elevation: 0,
    leading: Row(
      children: [
        IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
      
                context,
                MaterialPageRoute(builder: (context) => OverviewPage()),
              );
          },
        ),
      ],
    ),
    title: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          'assets/lsu.png',
          height: 40,
        ),
      ),
    ],
  );
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, ""),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/trees.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OverviewPage()),
              );
            },
            child: Text("Go to Second Page"),
          ),
        ),
      ),
    );
  }
}


class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  List<Map<String, dynamic>> clues = [];

  @override
  void initState() {
    super.initState();
    _loadClues();
  }

  Future<void> _loadClues() async {
    final String jsonString = await rootBundle.loadString('assets/clues.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      clues = List<Map<String, dynamic>>.from(jsonData["clues"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Overview"),
      body: clues.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: clues.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to Clue Page with ID
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CluePage(
                            id: clues[index]["id"],
                            question: clues[index]["question"],
                            answer: clues[index]["answer"],
                          ),
                        ),
                      );
                    },
                    child: Text("Clue ${clues[index]['id']}"),
                  ),
                );
              },
            ),
    );
  }
}

class CluePage extends StatelessWidget {
  final int id;
  final String question;
  final String answer;

  CluePage({required this.id, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Clue $id"),
      body: Center(
        child: Text(question, style: TextStyle(fontSize: 20)),
      ),
    );
  }
}