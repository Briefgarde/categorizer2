import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Result")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Thank you for your contribution !"),
              const SizedBox(height: 20),
              const Text("So what happened ?"),
              const Text("If you determined that none of the existing cases matched yours, a new case has been created, and will (maybe) be part of the next research you do."),
              const SizedBox(height: 20),
              const Text("If you determined that one of one of the existing cases matched yours, the system updated this case with your contribution, which mean it will not clutter the result set as a virtually separate case anymore."),
              const Text("The existing case and your issue are now considered the same case with two different contributions."),
              const Text("This means that if someone else contributes to this case, they will see your contribution as well as the existing case."),
              const SizedBox(height: 20),
              const Text("In any case, you may now go back to the start of the POC and try again, changing either the location or the picture, and see the cases you get."),
              const Text("Maybe yours will be part of the results this time !"),
              ElevatedButton(
                onPressed: () {
                  //reset the issue to nothing 
                  
                  //go back to the start of the POC
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Go back")
              )
            ],
          ),
        ),
      ),
    );
  }
}