import 'package:cloud_firestore/cloud_firestore.dart';

// Function to add a document to a collection
Future<void> addDocumentToCollection(Map<String, dynamic> data, String collectionName) async {
  try {
    await FirebaseFirestore.instance.collection(collectionName).add(data);
    print('Document added successfully');
  } catch (e) {
    print('Error adding document: $e');
  }
}

// Function to retrieve all documents from a collection
Future<List<DocumentSnapshot>> getAllDocumentsFromCollection(String collectionName) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).get();
    return querySnapshot.docs;
  } catch (e) {
    print('Error retrieving documents: $e');
    return [];
  }
}
