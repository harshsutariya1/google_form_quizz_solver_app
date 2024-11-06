import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/form_data.dart';
import 'package:quizz_app/custom_widgets.dart/form_data_tiles.dart';
import 'package:quizz_app/services/api_services.dart';
import 'package:quizz_app/services/storage_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> quizData = [];
  TextEditingController inputField = TextEditingController();

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
      persistentFooterButtons: [_bottomSearchBar()],
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FutureBuilder(
        future: getListOfFormIds(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          } else if (snapshot.hasData) {
            final List<String> listOfFormIds = snapshot.data;
            print("saved forms: $listOfFormIds");
            if (listOfFormIds == [] || listOfFormIds.isEmpty) {
              return const Center(
                child: Text("No Data Found!"),
              );
            } else {
              return ListView.builder(
                itemCount: listOfFormIds.length,
                itemBuilder: (BuildContext context, int index) {
                  return FutureBuilder(
                    future: getStoredQuizData(listOfFormIds[index]),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text("Error while fetching data"),
                        );
                      } else if (snapshot.hasData) {
                        final List quizData = snapshot.data;

                        return formDataTileShort(
                          context,
                          quizData,
                          listOfFormIds[index],
                          () async {
                            // Remove the formId
                            final result = await deleteFormId(
                                formId: listOfFormIds[index]);
                            setState(() {
                              if (result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Form Data Deleted."),
                                  ),
                                );
                                print("Form deleted");
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error deleting Form Data."),
                                  ),
                                );
                                print("Error deleting Form Data");
                              }
                            });
                          },
                        );
                      } else {
                        return const Center(
                          child: Text("Error while getting saved data"),
                        );
                      }
                    },
                  );
                },
              );
            }
          } else if (snapshot.hasError || snapshot.data == []) {
            return const Center(
              child: Text("Error while getting saved data"),
            );
          } else {
            return const Text("Error while getting saved data");
          }
        },
      ),
    );
  }

  Widget _bottomSearchBar() {
    return Container(
      height: 50,
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(
        bottom: 20,
        right: 5,
        left: 5,
      ),
      decoration: BoxDecoration(
        color: Colors.deepPurple[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.add),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: inputField,
                decoration: const InputDecoration(
                  hintText: "Add Google Form link",
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _onTapSend,
            icon: const Icon(Icons.send),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  void _onTapSend() {
    if (inputField.text.isNotEmpty) {
      fetchQuizData(
        googleFormLink: inputField.text,
        ifsuccessCode: (response) {
          setState(() {
            quizData = jsonDecode(response.body);
            print("Responce after scraping google form: $quizData");
          });
        },
      ).then((bool value) {
        if (value) {
          List<dynamic> generatedAnswers = [];
          generateResponse(ifsuccessCode: (response) {
            generatedAnswers = jsonDecode(response.body);
          }).then((value) {
            // Save QuizData
            saveQuizData(
              quizData: quizData,
              answersList: generatedAnswers,
            ).then((value) {
              // Navigate to show data screen
              if (value[0]) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FormData(
                      formId: value[1],
                    ),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Form Data saved."),
                  ),
                );
              } else {
                // show popup error saving data
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error saving data."),
                  ),
                );
              }
            });
          });
        }
      });
    } else {
      print("Please Enter Form Link");
    }
  }
}
