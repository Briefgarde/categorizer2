import 'package:categorizer2/models/case.dart';
import 'package:categorizer2/models/issue.dart';
import 'package:categorizer2/widgets/cases_shower.dart';
import 'package:flutter/material.dart';


class CaseReviewer extends StatefulWidget {
  const CaseReviewer({Key? key, required this.issue}) : super(key: key);
  final Issue issue;

  @override
  State<CaseReviewer> createState() => _CaseReviewerState();
}

class _CaseReviewerState extends State<CaseReviewer> {
  List<Case> _cases = [];
  late Future<List<Case>> _casesFuture;

  @override
  void initState() {
    super.initState();
    _casesFuture = getGoodCases();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Case Reviewer"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FutureBuilder(
                  future: _casesFuture,
                  builder: (BuildContext context, AsyncSnapshot<List<Case>> snapshot) {
                    if (snapshot.hasData) {
                      _cases = snapshot.data!;
                      if (_cases.isNotEmpty) {
                        return CaseShower(cases: _cases, issue: widget.issue);
                      } else {
                        return _noCaseFound();
                      }
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    else {
                      return const LoadingWidget();
                    }
                  },
                )
                // Text(widget.issue.coordinates.toString()),
                // Image.file(widget.issue.image!),
                // Text(widget.issue.image!.path),
              ],
            ),
          ),
        ));
  }

  Widget _noCaseFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Your case has been analyzed but no similar cases were found, so we created a new one !", 
              textAlign: TextAlign.center,
            ),
            const Text(
              "You should go back to the start and try again with a different picture or a different localisation.", 
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: () {
                
                Navigator.popUntil(context, (route) => route.isFirst);
              }, 
              child: const Text("Go back")
            ),
          ],
        ),
      ),
    );
    
    
    //return const Text("Your case has been analyzed but no similar cases were found, so we created a new one !");
  }

  Future<List<Case>> getGoodCases() async {
    return widget.issue.getGoodCases();
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Analyzing your issue..."),
          CircularProgressIndicator(),
        ],
      ),
    );
  }
}
