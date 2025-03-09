import 'dart:convert';
import 'package:flutter/material.dart';
import 'clue_state.dart'; // Import the clue state file

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for early SharedPreferences access
  await loadClueState(); 
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      // Define the initial route
      initialRoute: '/',
      // Define routes
      routes: {
        '/': (context) => StartPage(),
        '/overview': (context) => OverviewPage(),
      },
    );
  }
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
            if (ModalRoute.of(context)?.settings.name != '/overview') {
              Navigator.pushReplacementNamed(
                context,
                '/overview',
              );
            }
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Welcome to the Scavenger Hunt! Start outside of PFT and face the building from the north side. If at any point you need a hint, view the pop up when the incorrect answer is entered. Good luck!",
                  style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                ),
              SizedBox(height: 20), // Add some space between the text and the button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    '/overview',
                  );
                },
                child: Text("Start Hunt"),
              ),
            ],
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
        : Column(
            children: [
              // Add your custom button at the top here
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50), // full width button
                    backgroundColor: Colors.blue, 
                  ),
                  
                  onPressed: () {
                    // Add your button action here
                    Navigator.pushReplacementNamed(
                      context,
                      '/',
                    );
                  },
                  child: Text("Instructions",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Remaining space goes to the ListView
              Expanded(
                child: ListView.builder(
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBackgroundColor: const Color.fromARGB(106, 158, 158, 158),
                          backgroundColor: isCompleted ? Colors.green : 
                                          !isAccessible ? Colors.grey : null,
                        ),
                        onPressed: isAccessible ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CluePage(
                                id: clueId,
                                question: clue["question"],
                                answer: clue["answer"],
                                isCompleted: isCompleted,
                              ),
                            ),
                          );
                        } : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (isCompleted) Text("${clue["location"]}")
                            else if (!isCompleted) Text("${clue["title"]}"),
                            if (isCompleted) Icon(Icons.check_circle, color: Colors.white)
                            else if (!isAccessible) Icon(Icons.lock, color: Colors.white70),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        await resetClueProgress();
        setState(() {});
      },
      child: Icon(Icons.refresh),
      tooltip: "Reset Progress",
    ),
  );
}
}

bool compareAnswers(String answer1, String answer2) {
  return answer1.toLowerCase().trim() == answer2.toLowerCase().trim();
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
  TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller when the page is disposed
    super.dispose();
  }
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
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              // Display either "Mark as Completed" button or "Completed!" text
              if (widget.id + 1 > clues.length && isClueCompleted(widget.id))
              Column(
                children: [
                  //// TODO: Add a completion message
                  Text(
                    "Congratulations!", 
                    style: TextStyle(
                      color: Colors.green, 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        '/overview',
                      );
                    },
                    child: Text("Return to Overview"),
                  )
                ],
              )
              else if (!isClueCompleted(widget.id))
              Column(children: [
                Padding(padding: const EdgeInsets.all(10.0),
                child:
                TextField(
                controller: _controller,
                decoration: InputDecoration(
                labelText: 'Your Answer', // Label for the text field
                hintText: 'Type your answer here...', // Placeholder text
                fillColor: Color.fromARGB(125, 255, 255, 255), // Background color for the text field
                filled: true, // Fill the background with the above color
                border: OutlineInputBorder(),
                ),
                ),    
                ),            
                  ElevatedButton(
                    onPressed: () async {
                      if (compareAnswers(_controller.text, widget.answer)) {
                        await markClueCompleted(widget.id);
                        setState(() { });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Incorrect. Hint: ${clues[widget.id-1]["hint"]}"),
                          ),
                        );
                      }
                    },
                    child: Text("Mark as Completed"),
                  )
                ],
              )
              else
              Column(
                children: [
                    Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      clues[widget.id-1]["blurb"], 
                      style: TextStyle(
                      color: Colors.green, 
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ),
                  if (widget.id + 1 <= clues.length)
                  ElevatedButton(
                    onPressed: () {
                      int nextId = widget.id + 1;
                        Navigator.pushReplacement(
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