import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> quizData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("History"),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {},
        child: _body(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchQuizData();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      persistentFooterButtons: [_bottomSearchBar()],
    );
  }

  Widget _body2() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            quizData.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
                    child: ListView.builder(
                      itemCount: quizData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final questions =
                            quizData[index]['question'] ?? "Questions NA";
                        final answeres = quizData[index]['options'] ?? [];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(questions),
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap:
                                    true, // Important for nested ListView
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: answeres.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Text(answeres[index]);
                                },
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    return const Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [],
      ),
    );
  }

  Widget _bottomSearchBar() {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 20,
        right: 5,
        left: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple[200],
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Future<void> fetchQuizData(
      {String googleFormLink = "https://forms.gle/QTovj8DYWRXAQdu67"}) async {
    try {
      print("Getting quizz data");
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:8000/get_quiz_data?google_form_link=$googleFormLink',
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          quizData = jsonDecode(response.body);
          print("Responce from api: $quizData");
        });
      } else {
        throw Exception('Failed to load quiz data');
      }
    } catch (e) {
      print("Failed to load quizz data $e");
    }
  }
}
