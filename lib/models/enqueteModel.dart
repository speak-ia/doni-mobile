import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Enquete {
  final String surveyId; 
  final String title;
  final String description;
  final String status;
  final String startDate;
  final String endDate;
  final String investigatorId; // Rendu optionnel avec une valeur par défaut

  Enquete({
    required this.surveyId, 
    required this.title,
    required this.description,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.investigatorId = "", // Valeur par défaut pour le rendre optionnel
  });

  factory Enquete.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Enquete(
      surveyId: doc.id, 
      title: data['title'] ?? 'Survey not found',
      description: data['description'] ?? '',
      status: data['status'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      investigatorId: data['investigatorId'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId, 
      'title': title,
      'description': description,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
    'investigatorId': investigatorId, 
    };
  }
}