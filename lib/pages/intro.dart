

import 'package:categorizer2/pages/image_selector.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text("Disclaimer"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    Text("This is a proof of concept"),
                    Text("Concerns such as graphic design or usability have not been taken into account"),
                    Text("The only thing we've made here is a prototype.\n" 
                      "A real, industry-ready version of this functionnality would need to be mostly remade from scratch"
                    ),
                  ],
                )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ImageSelector()));
                    },
                    child: const  Text("I understand"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Image(image: AssetImage("assets/images/wedontdothathere.jpg")),
                        ),
                      );
                    },
                    child: const Text("I expect better"),
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