import 'dart:convert';
import 'package:flutter/material.dart';
import 'clue_state.dart'; // Import the clue state file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for early SharedPreferences access
  await loadClueState(); 
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

Decoration buildBackground() {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/trees.jpg'),
      fit: BoxFit.cover,
    ),
  );
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(context, ""),
      body: Container(
        decoration: buildBackground(),
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Overview"),
      body: Container(
        decoration: buildBackground(),
        child: clues.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: clues.length,
              itemBuilder: (context, index) {
                final clue = clues[index];
                final clueId = clue["id"];
                final isCompleted = isClueCompleted(clueId);
                final isAccessible = isClueAccessible(clueId);
                
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? Colors.green : 
                                       !isAccessible ? Colors.grey : null,
                    ),
                    onPressed: isAccessible ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CluePage(
                            id: clueId,
                            question: clue["question"],
                            answer: clue["answer"],
                            isCompleted: isCompleted,
                          ),
                        ),
                      ); // Refresh when returning
                    } : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Clue $clueId"),
                        if (isCompleted) Icon(Icons.check_circle, color: Colors.white)
                        else if (!isAccessible) Icon(Icons.lock, color: Colors.white70),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
      // Optional: Add a reset button for testing
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await resetClueProgress();
          setState(() {}); // Refresh the UI
        },
        child: Icon(Icons.refresh),
        tooltip: "Reset Progress",
      ),
    );
  }
}

class CluePage extends StatefulWidget {
  final int id;
  final String question;
  final String answer;
  final bool isCompleted;

  CluePage({
    required this.id, 
    required this.question, 
    required this.answer, 
    this.isCompleted = false,
  });

  @override
  _CluePageState createState() => _CluePageState();
}

class _CluePageState extends State<CluePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Clue ${widget.id}"),
      body: Container(
        decoration: buildBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display the clue question
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.question, 
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Display either "Mark as Completed" button or "Completed!" text
              if (!isClueCompleted(widget.id))
                ElevatedButton(
                  onPressed: () async {
                    await markClueCompleted(widget.id);
                    setState(() { });
                  },
                  child: Text("Mark as Completed"),
                )
              else
              Column(
                children: [
                  Text(
                    "Completed!", 
                    style: TextStyle(
                      color: Colors.green, 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )
                  ),
                  ElevatedButton(
                    onPressed: () {
                      int nextId = widget.id + 1;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CluePage(
                              id: nextId,
                              question: clues[nextId-1]["question"],
                              answer: clues[nextId-1]["answer"],
                              isCompleted: isClueCompleted(nextId),
                            ),
                          ),
                        );
                    },
                    child: Text("Next Clue"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}