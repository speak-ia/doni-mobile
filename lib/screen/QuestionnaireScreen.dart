import 'package:donidata/models/enqueteModel.dart';
import 'package:donidata/provider/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donidata/provider/QuestionProvider.dart';
import 'package:donidata/provider/enquete_provider.dart'; 
import 'package:donidata/screen/accueil.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String surveyId; 

  QuestionnaireScreen({required this.surveyId});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _currentQuestionIndex = 0;
  String? selectedAnswer; // "Oui", "Non", ou une réponse textuelle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
      print("Appel de fetchQuestions avec surveyId: ${widget.surveyId}");
      questionProvider.fetchQuestions(widget.surveyId);
    });
  }

  void _nextQuestion() {
    final questionProvider = Provider.of<QuestionProvider>(context, listen: false);
    print("Passage à la question suivante. Index actuel : $_currentQuestionIndex, Total questions : ${questionProvider.questions.length}");
    if (_currentQuestionIndex < questionProvider.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        selectedAnswer = null; // Réinitialise la réponse pour la nouvelle question
      });
    } else {
      _finishQuestionnaire();
    }
  }

  void _finishQuestionnaire() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Survey Completed"),
          content: Text("Thank you for participating in our survey!"),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Accueil()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionProvider = Provider.of<QuestionProvider>(context);
    final enqueteProvider = Provider.of<EnqueteProvider>(context, listen: false); 
    final userProvider = Provider.of<UserProvider>(context);
    final questions = questionProvider.questions;
    final currentEnquete = enqueteProvider.enquetes.firstWhere(
      (enquete) => enquete.surveyId == widget.surveyId,
      orElse: () => Enquete(
        surveyId: "", 
        title: "Survey not found",
        description: "",
        status: "",
        startDate: "",
        endDate: "",
        investigatorId: userProvider.user?.uid ?? "", 
      ),
    );

    final bool isLastQuestion = _currentQuestionIndex == questions.length - 1;

    if (questionProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          elevation: 0,
          title: Text(currentEnquete.title),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          elevation: 0,
          title: Text(currentEnquete.title),
        ),
        body: Center(child: Text("No questions available for this survey.")),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final currentUser = userProvider.user; 
    print("Questions chargées : $questions, Longueur : ${questions.length}, Index courant : $_currentQuestionIndex");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        elevation: 0,
        title: Text(currentEnquete.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.lightBlue[100],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion.text,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (currentQuestion.type == 'boolean')
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedAnswer = "Oui";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedAnswer == "Oui" ? Colors.green : Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Oui",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedAnswer = "Non";
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedAnswer == "Non" ? Colors.green : Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Non",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                )
              else if (currentQuestion.type == 'text')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Your answer',
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedAnswer = value; 
                      });
                    },
                    controller: TextEditingController(text: selectedAnswer ?? ''),
                  ),
                )
              else
                Text("Type de question non pris en charge : ${currentQuestion.type}"),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedAnswer == null
                    ? null
                    : () {
                        final answer = Answer(
                          questionId: currentQuestion.id,
                          response: selectedAnswer!,
                          surveyId: currentQuestion.surveyId,
                          investigatorId: currentUser?.uid ?? "",
                        );
                        questionProvider.submitAnswer(answer);
                        _nextQuestion();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLastQuestion ? "Finish" : "Ok",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}