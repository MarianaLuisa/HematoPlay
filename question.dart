//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hematoplay/main.dart';
import 'widgets/answer_options.dart';
import 'widgets/answer_images.dart';

class Question extends StatefulWidget {
  const Question({super.key, required this.title, required this.categoryId});

  final String title;
  final String categoryId;

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  bool nextIsVisible = false;
  bool gestureEnabled = true;

  var colorMap = {
    'alternativa1': Colors.deepPurple.shade200,
    'alternativa2': Colors.deepPurple.shade200,
    'alternativa3': Colors.deepPurple.shade200,
    'alternativa4': Colors.deepPurple.shade200,
  };

  @override
  Widget build(BuildContext context) {
    if (!answereds.containsKey(widget.categoryId)) {
      answereds[widget.categoryId] = [];
    }

    return PopScope(
      onPopInvoked: (bool didpop) {
        if (didpop) {
          if (questionCounter > 1 && !isFinished) {
            while (questionCounter > 1) {
              answereds[widget.categoryId]!.removeLast();
              questionCounter -= 1;
            }
          }

          questionCounter = 1;
          correctCounter = 0;
          isFinished = false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        body: answereds[widget.categoryId]!.length == 11
            ? endQuestions()
            : FutureBuilder<QuerySnapshot>(
                future: answereds[widget.categoryId]!.length == 0
                    ? FirebaseFirestore.instance
                        .collection('categorias')
                        .doc(widget.categoryId)
                        .collection(widget.categoryId == 'saHwtWWrxoqzL8L0al5p'
                            ? 'perguntas '
                            : 'perguntas')
                        .limit(1)
                        .get()
                    : FirebaseFirestore.instance
                        .collection('categorias')
                        .doc(widget.categoryId)
                        .collection(widget.categoryId == 'saHwtWWrxoqzL8L0al5p'
                            ? 'perguntas '
                            : 'perguntas')
                        .where(FieldPath.documentId,
                            whereNotIn: answereds[widget.categoryId])
                        .limit(1)
                        .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Align(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty ||
                      isFinished) {
                    if (questionCounter == 1 &&
                        answereds[widget.categoryId]!.length == 0) {
                      return noQuestions(widget: widget);
                    } else if (questionCounter == 1 &&
                        answereds[widget.categoryId]!.length > 0) {
                      return endQuestions();
                    } else {
                      return resultQuiz(context);
                    }
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<DocumentSnapshot> documents = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            documents[index].data() as Map<String, dynamic>;
                        String documentId = documents[index].id;
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 10),
                          child: Column(
                            children: [
                              Text('${questionCounter} / ${totalQuestions}',
                                  style: TextStyle(fontSize: 20)),
                              const SizedBox(height: 10),
                              data['imagem'] != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            30.0), // Apply rounded corners to the container
                                        border: Border.all(
                                          width: 15.0,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Apply rounded corners to the image
                                        child: Image.network(
                                          data['imagem'],
                                          fit: BoxFit.fill,
                                          scale: 0.5,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.deepPurple),
                                      child: Text(
                                        data['titulo'],
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                              const SizedBox(height: 20),
                              data['titulo'] != null
                                  ? AnswerImages(
                                      data: data,
                                      colorMap: colorMap,
                                      onTap: (option) {
                                        handleAnswerOption(option, data);
                                      },
                                    )
                                  : AnswerOptions(
                                      data: data,
                                      colorMap: colorMap,
                                      onTap: (option) {
                                        handleAnswerOption(option, data);
                                      },
                                    ),
                              const SizedBox(height: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    answereds[widget.categoryId]!
                                        .add(documentId);

                                    questionCounter += 1;
                                    nextIsVisible = false;
                                    gestureEnabled = true;
                                    colorMap['alternativa1'] =
                                        Colors.deepPurple.shade200;
                                    colorMap['alternativa2'] =
                                        Colors.deepPurple.shade200;
                                    colorMap['alternativa3'] =
                                        Colors.deepPurple.shade200;
                                    colorMap['alternativa4'] =
                                        Colors.deepPurple.shade200;

                                    if (questionCounter > totalQuestions) {
                                      isFinished = true;
                                    }
                                  });
                                },
                                child: Visibility(
                                  visible: nextIsVisible,
                                  child: Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: const Align(
                                        child: Text(
                                      "Próxima",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
      ),
    );
  }

  Column resultQuiz(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.deepPurple.shade50),
          margin: EdgeInsets.all(30),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                const Align(
                  child: Text(
                    'Sua pontuação final foi:',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '$correctCounter / $totalQuestions',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 40,
                  ),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 30, right: 30),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Align(
                child: Text(
              "Novo Quiz",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }

  Column endQuestions() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.deepPurple.shade50),
          margin: const EdgeInsets.all(30),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'As perguntas para este nível acabaram por enquanto, mas você pode refazer!',
              style: TextStyle(color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              answereds[widget.categoryId] = [];
            });
          },
          child: Container(
            margin: const EdgeInsets.only(left: 30, right: 30),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Align(
                child: Text(
              "Refazer",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }

  void handleAnswerOption(String option, Map<String, dynamic> data) {
    if (gestureEnabled) {
      setState(() {
        nextIsVisible = true;
        gestureEnabled = false;
        if (data["correta"] == option) {
          correctCounter += 1;
          colorMap[option] = Colors.green;
        } else {
          colorMap[option] = Colors.red;
          colorMap[data["correta"]] = Colors.green;
        }
      });
    }
  }
}

class noQuestions extends StatelessWidget {
  const noQuestions({
    super.key,
    required this.widget,
  });

  final Question widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.deepPurple.shade50),
          margin: const EdgeInsets.all(30),
          child: const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Em breve estaremos adicionando perguntas para este nível!',
              style: TextStyle(color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            answereds[widget.categoryId] = [];
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 30, right: 30),
            height: 40,
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Align(
                child: Text(
              "Voltar",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
          ),
        )
      ],
    );
  }
}
