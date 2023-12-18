import 'package:categorizer2/models/issue.dart';
import 'package:categorizer2/pages/cases_reviewer.dart';
import 'package:categorizer2/pages/map_screen.dart';
import 'package:flutter/material.dart';

class LocationDecider extends StatelessWidget {
  const LocationDecider({Key? key, required this.issue}) : super(key: key);
  final Issue issue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Where are you ?"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text("Here is the picture you took"),
              Expanded(child: Image.file(issue.image!),),
              const Text("To help us categorize your issue, we need to know where it is."),
              const Text("Are you currently where you took the picture ?"),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => MapScreen(issue: issue)
                        )
                      );
                    }, 
                    child: const Text("No")
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => CaseReviewer(issue: issue)
                        )
                      );
                    }, 
                    child: const Text("Yes")
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



