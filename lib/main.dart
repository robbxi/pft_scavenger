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
      title: 'PFT Scavenger',
      theme: ThemeData(fontFamily: 'ProximaNova'),
      // Define the initial route
      initialRoute: '/',
      // Define routes
      routes: {
        '/': (context) => StartPage(),
        '/overview': (context) => OverviewPage(),
        '/map': (context) => MapPage(),
      },
    );
  }
}

AppBar buildAppBar(BuildContext context, String title) {
  return AppBar(
    automaticallyImplyLeading: false,
    shape: Border(
      bottom: BorderSide(
        color: Color(0x33333333),
        width: 4.0,
      ),
    ),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        color: Color(0xffFDD023),
      ),
    ),
    elevation: 0,
    titleSpacing: 0, // Ensures proper alignment
    title: Row(
      children: [
        // Left Icons (Fixed Width)
        SizedBox(
          width: 100, // Reserve space for icons
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ModalRoute.of(context)?.settings.name != '/overview')
                IconButton(
                  icon: Icon(Icons.home, color: Color(0xFF461D7C)),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/overview');
                  },
                ),
              if (ModalRoute.of(context)?.settings.name != '/map')
                IconButton(
                  icon: Icon(Icons.map, color: Color(0xFF461D7C)),
                  iconSize: 30,
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/map');
                  },
                ),
            ],
          ),
        ),

        // Title (Expands to Available Space)
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(color: Color(0xFF333333), fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Right Logo (Fixed Width)
        SizedBox(
          width: 80, // Reserve space for the logo
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/lsu.png',
              height: 40,
            ),
          ),
        ),
      ],
    ),
  );
}








Decoration buildBackground() {
  return BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/lsutree.jpg'),
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Welcome card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Color(0xFF461D7C),
                          ),
                          SizedBox(height: 16),
                          Text(
                            "Welcome to the Scavenger Hunt!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          Text(
                            "Start outside of PFT and face the building from the north side. If at any point you need a hint, view the pop up when the incorrect answer is entered, or if you need more help, click the map icon to see where you should go. Good luck!",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Start button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/overview');
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Start Hunt",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF333333),
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(Icons.play_arrow, color: Color(0xFF461D7C)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
    final completedCount = clues.where((clue) => isClueCompleted(clue["id"])).length;
    final progress = clues.isEmpty ? 0.0 : completedCount / clues.length;

    return Scaffold(
      appBar: buildAppBar(context, "Overview"),
      body: Container(
        decoration: buildBackground(),
        child: clues.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD29F13)),
                          minHeight: 25,
                        ),
                        Text(
                        "$completedCount/${clues.length} Clues Completed",
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        )
                        ],
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
                // Instructions button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Color(0xFF461D7C),
                      elevation: 2,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text(
                      "Instructions",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Clues list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: clues.length,
                    itemBuilder: (context, index) {
                      final clue = clues[index];
                      final clueId = clue["id"];
                      final isCompleted = isClueCompleted(clueId);
                      final isAccessible = isClueAccessible(clueId);
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.only(bottom: 12),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: const Color.fromARGB(137, 158, 158, 158),
                            backgroundColor: isCompleted 
                              ? Color(0xFFD29F13).withOpacity(0.95)
                              : !isAccessible 
                                ? Colors.grey.withOpacity(0.95)
                                : Colors.white.withOpacity(0.95),
                            elevation: 2,
                            padding: EdgeInsets.symmetric(vertical: 16),
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
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Text(
                                    isCompleted ? clue["location"] : clue["title"],
                                    style: TextStyle(
                                      color: isCompleted || !isAccessible ? Color(0xff333333) : Colors.black87,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              if (isCompleted)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Icon(Icons.check_circle, color: Colors.white),
                                )
                              else if (!isAccessible)
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Icon(Icons.lock, color: const Color.fromARGB(209, 255, 255, 255)),
                                ),
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
      floatingActionButton: isClueCompleted(clues.length)
        ? FloatingActionButton(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Reset Progress'),
                  content: Text('Are you sure you want to reset all your progress? This cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Reset', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              
              if (confirmed == true) {
                await resetClueProgress();
                setState(() {});
              }
            },
            child: Icon(Icons.refresh),
            tooltip: "Reset Progress",
          )
        : null,
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
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, clues[widget.id-1]["title"]),
      body: Container(
        decoration: buildBackground(),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  // Clue number indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFA39AAC).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Clue ${widget.id} of ${clues.length}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Question card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  if (widget.id + 1 > clues.length && isClueCompleted(widget.id))
                    _buildCompletionCard()
                  else if (!isClueCompleted(widget.id))
                    _buildAnswerInput()
                  else
                    _buildCompletedCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.amber,
            ),
            SizedBox(height: 16),
            Text(
              "Congratulations! 🎉",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "You have completed the hunt! You should now be around where you started. You can click return to overview to see your path and the clues you have completed. If you would like to reset your progress you can do so with the button in the bottom right of the overview page. Good job and Thanks for playing!",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/overview');
              },
              child: Text(
                "Return to Overview",
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Column(
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            
            hintText: 'Type your answer here...',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Color(0xFF461D7C), width: 2),
            ),
          ),
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isSubmitting ? null : () async {
            setState(() => _isSubmitting = true);
            
            if (compareAnswers(_controller.text, widget.answer)) {
              await markClueCompleted(widget.id);
              setState(() { });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Incorrect. Hint: ${clues[widget.id-1]["hint"]}"),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            
            setState(() => _isSubmitting = false);
          },
          child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                "Submit Answer",
                style: TextStyle(fontSize: 18),
              ),
        ),
      ],
    );
  }

  Widget _buildCompletedCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 64,
              color: Color(0xFFD29F13),
            ),
            SizedBox(height: 16),
            Text(
              "Completed!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD29F13),
              ),
            ),
            SizedBox(height: 16),
            Text(
              clues[widget.id-1]["blurb"],
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.id + 1 <= clues.length) ...[
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Next Clue",
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, "Map"),
      body: Container(
        decoration: buildBackground(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    "Explore the map to help find clues, the red circle is where you should look, the red line shows your path.",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              InteractiveViewer(
                panEnabled: true, // Allow panning
                boundaryMargin: EdgeInsets.all(20),
                minScale: 0.5, // Minimum zoom scale
                maxScale: 4.0, // Maximum zoom scale
                child: Image.asset(
                  'assets/clue$highestAccessibleClueId.jpg', // Replace with your map image path
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}