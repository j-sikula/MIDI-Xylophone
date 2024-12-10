import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:midi_xylophone/control/serial_port_handler.dart';

/// NoteDisplayer widget
/// Displays the current note and the previous notes
/// when not decoded as a note, displays the raw data
class NoteDisplayer extends StatefulWidget {
  final SerialPortHandler? serialPortHandler;

  const NoteDisplayer({super.key, required this.serialPortHandler});

  @override
  NoteDisplayerState createState() => NoteDisplayerState();
}

/// State class for the NoteDisplayer widget
class NoteDisplayerState extends State<NoteDisplayer> {
  String previousNotes = '';
  String currentNote = '';
  final ScrollController _scrollController = ScrollController();
  final String notesRepresentation = 'CDEFGAHC';

  /// Clears the display text
  /// not used in the project
  void clearDisplayText() {
    setState(() {
      previousNotes = '';
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Builds the widget
  /// Displays the current note and the previous notes
  /// Uses a StreamBuilder to display the received data stream
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Scrollbar(
        controller: _scrollController,
        child: SingleChildScrollView(
            controller: _scrollController,
            child: Center(
              child: widget.serialPortHandler != null
                  ? StreamBuilder<String>(
                      stream: widget.serialPortHandler!.receivedData!,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Column(
                            children: [
                              CircularProgressIndicator(),
                              Text("Waiting for data...")
                            ],
                          ); // Display a loading indicator when waiting for data.
                        } else if (snapshot.hasError) {
                          log('Error: ${snapshot.error}');
                          return const Text(
                              "No serial monitor available"); // Display an error message if an error occurs.
                        } else if (snapshot.hasData) {
                          previousNotes =
                              '$currentNote\n$previousNotes'; // Append new data to displayText.

                          // Check if the received data is a valid note index
                          int? noteIndex = int.tryParse(snapshot.data!);
                          if (noteIndex != null &&
                              noteIndex >= 0 &&
                              noteIndex < notesRepresentation.length) {
                            currentNote = notesRepresentation.substring(
                                noteIndex, noteIndex + 1);
                            if (noteIndex / 7 >= 1) {
                              // Add subscript to note
                              currentNote += '\u2082'; // Unicode subscript 1
                            } else {
                              currentNote += '\u2081'; // Unicode subscript 2
                            }
                          } else {
                            currentNote =
                                snapshot.data!; // Display the raw data
                          }

                          return Column(
                            children: [
                              AnimatedSwitcher(
                                // Animate the note change
                                duration: const Duration(milliseconds: 100),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  currentNote,
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                  key: ValueKey<String>(currentNote),
                                ),
                              ),
                              Text(previousNotes),
                            ],
                          );
                        } else {
                          return const Text(
                              'No data available'); // Display a message when no data is available.
                        }
                      },
                    )
                  : const Text("No serial port handler found!"),
            )),
      ),
    );
  }
}
