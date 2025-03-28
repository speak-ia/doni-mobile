import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Question {
  final String id;
  final String text;
  final String type; // "boolean" ou "text"
  final List<String> options; // ["Oui", "Non"] pour boolean, vide ou non pour text
  final String surveyId;

  Question({
    required this.id,
    required this.text,
    required this.type,
    required this.options,
    required this.surveyId,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] ?? '';
    if (type != 'boolean' && type != 'text') {
      throw Exception("Type de question non pris en charge : $type. Seuls 'boolean' et 'text' sont autorisés.");
    }

    return Question(
      id: doc.id,
      text: data['text'] ?? '',
      type: type,
      options: (data['options'] != null && data['options'] is List)
          ? List<String>.from(data['options']) // ["Oui", "Non"] pour boolean, vide ou autre pour text
          : (type == 'boolean' ? ["Oui", "Non"] : []), // Défaut : "Oui/Non" pour boolean, vide pour text
      surveyId: data['surveyId'] ?? '',
    );
  }
}

class Answer {
  final String questionId;
  final String response;
  final String surveyId;
  final String investigatorId;

  Answer({
    required this.questionId,
    required this.response,
    required this.surveyId,
    required this.investigatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'response': response,
      'surveyId': surveyId,
      'investigatorId': investigatorId,
    };
  }
}

class QuestionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Question> _questions = [];
  bool _isLoading = false;

  List<Question> get questions => _questions;
  bool get isLoading => _isLoading;

  Future<void> fetchQuestions(String surveyId) async {
    _isLoading = true;
    notifyListeners(); // Notifie immédiatement que le chargement commence

    print("Début de la récupération des questions pour surveyId: $surveyId");

    try {
      _questions = []; // Réinitialise la liste avant de charger de nouvelles questions
      QuerySnapshot querySnapshot = await _firestore
          .collection('questions')
          .where('surveyId', isEqualTo: surveyId)
          .get();

      print("Nombre de questions trouvées : ${querySnapshot.docs.length}");

      _questions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        print("Données Firestore pour la question ${doc.id}: $data");

        return Question.fromFirestore(doc); // Utilise la factory pour valider le type
      }).toList();

      print("Questions récupérées : $_questions");
    } catch (e) {
      print("Erreur lors de la récupération des questions : $e");
      _questions = []; // Réinitialise en cas d'erreur
    }

    _isLoading = false;
    notifyListeners(); // Notifie que le chargement est terminé
  }

  Future<void> submitAnswer(Answer answer) async {
    try {
      await _firestore.collection('answers').add(answer.toMap());
    } catch (e) {
      print("Erreur lors de la soumission de la réponse: $e");
    }
  }
}