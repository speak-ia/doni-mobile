import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:donidata/models/enqueteModel.dart';
import 'package:donidata/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class EnqueteProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Enquete> _enquetes = [];
  bool _isLoading = false;

  List<Enquete> get enquetes => _enquetes;
  bool get isLoading => _isLoading;

  Future<void> fetchEnquetes(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    try {
      QuerySnapshot snapshot = await _firestore.collection('surveys').get();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final investigatorId = userProvider.user?.uid ?? ""; 

      _enquetes = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Enquete(
          surveyId: doc.id, 
          title: data['title'] ?? 'Survey not found',
          description: data['description'] ?? '',
          status: data['status'] ?? '',
          startDate: data['startDate'] ?? '',
          endDate: data['endDate'] ?? '',
          investigatorId: data['investigatorId'] ?? investigatorId, 
        );
      }).toList();
    } catch (e) {
      print("Erreur lors de la récupération des enquêtes: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}