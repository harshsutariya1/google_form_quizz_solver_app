import 'package:flutter/material.dart';
import 'package:quizz_app/Screens/home.dart';
import 'package:quizz_app/custom_widgets.dart/form_data_tiles.dart';
import 'package:quizz_app/services/storage_services.dart';

class FormData extends StatefulWidget {
  const FormData({
    super.key,
    this.formId = "",
  });

  final String formId;
  @override
  State<FormData> createState() => _FormDataState();
}

class _FormDataState extends State<FormData> {
  @override
  void initState() {
    super.initState();
    print("Form Id: ${widget.formId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(),
              ),
            );
          },
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FutureBuilder(
        future: getStoredQuizData(widget.formId),
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

            return formDataTileLong(context, quizData);
          } else {
            return const Center(
              child: Text("Error while getting saved data"),
            );
          }
        },
      ),
    );
  }
}
