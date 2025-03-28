import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donidata/screen/QuestionnaireScreen.dart';
import 'package:donidata/screen/profil_screen.dart';
import 'package:donidata/provider/enquete_provider.dart';
import 'package:donidata/provider/userProvider.dart';
import 'package:donidata/models/enqueteModel.dart'; // Assure-toi d'importer le modèle Enquete

class EnqueteDetailPage extends StatefulWidget {
  final Map<String, String> enquete;

  EnqueteDetailPage({required this.enquete});

  @override
  _EnqueteDetailPageState createState() => _EnqueteDetailPageState();
}

class _EnqueteDetailPageState extends State<EnqueteDetailPage> {
  bool isApplied = false;
  bool isAccepted = false;

  void _applyForSurvey() {
    setState(() {
      isApplied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isAccepted = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Votre candidature a été acceptée ! Vous pouvez répondre aux questions."),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final enqueteProvider = Provider.of<EnqueteProvider>(context, listen: false); // Évite de réécouter ici

    // Trouver l'enquête correspondante dans EnqueteProvider en utilisant le titre ou une autre propriété unique
    final currentEnquete = enqueteProvider.enquetes.firstWhere(
      (enquete) => enquete.title == widget.enquete['title'],
      orElse: () => Enquete(
        surveyId: "",
        title: widget.enquete['title'] ?? "Survey not found",
        description: widget.enquete['description'] ?? "",
        status: "",
        startDate: "",
        endDate: "",
        investigatorId: user?.uid ?? "",
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundImage: user?.photoUrl != null
                  ? NetworkImage(user!.photoUrl!)
                  : AssetImage("assets/images/logo.png") as ImageProvider,
              radius: 30,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullname ?? 'Nom inconnu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              'Enquêteur',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.message,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              widget.enquete['title'] ?? "Titre de l'enquête",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              widget.enquete['description'] ?? "Description de l'enquête",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isApplied
                  ? null
                  : _applyForSurvey,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A1B34),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text(
                isApplied ? "Candidature envoyée" : "Postuler",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isApplied && !isAccepted)
              Text("Votre candidature est en attente de validation par l'admin.",
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            if (isAccepted)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionnaireScreen(surveyId: currentEnquete.surveyId), // Utilise le surveyId de l'enquête actuelle
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  "Répondre aux questions",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}