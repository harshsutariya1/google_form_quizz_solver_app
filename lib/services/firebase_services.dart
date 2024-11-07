import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

Future<String> getSecrets({
  bool laptopLocalhostIpLink = false,
  bool androidEmulatorLocalHostLink = false,
  bool deployedApiLink = false,
  bool openAiApiKey = false,
}) async {
  final docRef = FirebaseFirestore.instance
      .collection('secrets')
      .doc("CJsDaxEiW5noxGQz1BQR");
  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    if (laptopLocalhostIpLink) {
      print("Getting laptopLocalHostLink");
      return docSnapshot['laptop_local_ip_link'];
    }
    if (androidEmulatorLocalHostLink) {
      print("Getting androidEmulatorLocalHostLink");
      return docSnapshot['android_emulator_ip_link'];
    }
    if (deployedApiLink) {
      print("Getting deployedApiLink");
      return docSnapshot['deployed_api_link'];
    }
    if (openAiApiKey) {
      print("Getting openAiApiKey");
      return docSnapshot['openai_api_key'];
    }
  }
  return "Link not available.";
}

Future<void> updateUsageDetails({
  double totalTokenUsed = 0,
  String aiModel = "gpt-3.5-turbo-0125",
}) async {
  try {
    print("Total Token Used: $totalTokenUsed");
    final docRef = FirebaseFirestore.instance
        .collection('usage')
        .doc("KIDF1ujzTolENnv81ehP");
    final docSnapshot = await docRef.get();
    double totalCost = 0;
    double costPer1kToken = 0;

    // Calculate total cost
    if (aiModel == 'gpt-3.5-turbo-0125') {
      costPer1kToken = 0.0005;
    } else if (aiModel == 'gpt-3.5-turbo-0613') {
      costPer1kToken = 0.0015;
    } else if (aiModel == 'gpt-3.5-turbo-1106') {
      costPer1kToken = 0.0010;
    } else if (aiModel == 'gpt-4o-mini') {
      costPer1kToken = 0.00075;
    } else {
      costPer1kToken = 0.0005;
    }
    totalCost = (totalTokenUsed * costPer1kToken) / 1000;
    print("total cost of response: \$ $totalCost");

    Map<String, dynamic> updatedData = {
      'total_token_used': docSnapshot['total_token_used'] + totalTokenUsed,
      'total_cost': docSnapshot['total_cost'] + totalCost,
      'total_response_created': docSnapshot['total_response_created'] + 1,
    };
    await docRef.update(updatedData);
  } catch (e) {
    print("Error updating usage data...: $e");
  }
}

Future<List> getUsageDetails() async {
  // print("Getting Usage Details");
  final docRef = FirebaseFirestore.instance
      .collection('usage')
      .doc("KIDF1ujzTolENnv81ehP");
  final docSnapshot = await docRef.get();
  if (docSnapshot.exists) {
    final list = [
      docSnapshot['total_token_used'],
      docSnapshot['total_cost'],
      docSnapshot['total_response_created'],
    ];
    print("usage details: $list");
    return list;
  } else {
    return [0, 0, 0];
  }
}
