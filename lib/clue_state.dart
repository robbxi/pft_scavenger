import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
// Global variables to track clue state
Set<int> completedClueIds = {};
int highestAccessibleClueId = 1;
List<Map<String, dynamic>> clues = []; // Add the clues array here

// Load the saved state and clues
Future<void> loadClueState() async {
  // Load clues from JSON file
  final String jsonString = await rootBundle.loadString('assets/clues.json');
  final Map<String, dynamic> jsonData = json.decode(jsonString);
  clues = List<Map<String, dynamic>>.from(jsonData["clues"]);
  
  // Load completion state from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Load completed clue IDs
  final List<String>? completedCluesStrings = prefs.getStringList('completed_clues');
  if (completedCluesStrings != null) {
    completedClueIds = completedCluesStrings.map((idStr) => int.parse(idStr)).toSet();
  }
  
  // Load highest accessible clue ID
  highestAccessibleClueId = prefs.getInt('highest_accessible_clue') ?? 1;
}

// Save the state
Future<void> saveClueState() async {
  final prefs = await SharedPreferences.getInstance();
  
  // Save completed clue IDs
  await prefs.setStringList(
    'completed_clues',
    completedClueIds.map((id) => id.toString()).toList(),
  );
  
  // Save highest accessible clue ID
  await prefs.setInt('highest_accessible_clue', highestAccessibleClueId);
}

// Mark a clue as completed
Future<void> markClueCompleted(int clueId) async {
  completedClueIds.add(clueId);
  
  // Update highest accessible clue if needed
  if (clueId >= highestAccessibleClueId && clueId < clues.length) {
    highestAccessibleClueId = clueId + 1;
  }
  
  // Save changes
  await saveClueState();
}

// Check if a clue is accessible
bool isClueAccessible(int clueId) {
  return clueId <= highestAccessibleClueId;
}

// Check if a clue is completed
bool isClueCompleted(int clueId) {
  return completedClueIds.contains(clueId);
}

// Reset all progress (for testing)
Future<void> resetClueProgress() async {
  completedClueIds.clear();
  highestAccessibleClueId = 1;
  await saveClueState();
}