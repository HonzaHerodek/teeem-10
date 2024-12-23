import 'package:flutter/material.dart';
import '../../../../../data/models/step_type_model.dart';
import 'step_type_form_base.dart';

class QuizStepForm extends StepTypeFormBase {
  const QuizStepForm({
    Key? key,
    required StepTypeModel stepType,
    required VoidCallback onCancel,
    required Function(Map<String, dynamic>) onSave,
  }) : super(
          key: key,
          stepType: stepType,
          onCancel: onCancel,
          onSave: onSave,
        );

  @override
  QuizStepFormState createState() => QuizStepFormState();
}

class QuizQuestion {
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctOptionIndex;

  QuizQuestion()
      : questionController = TextEditingController(),
        optionControllers = List.generate(4, (_) => TextEditingController()),
        correctOptionIndex = 0;

  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'question': questionController.text,
      'options': optionControllers.map((c) => c.text).toList(),
      'correctAnswer': correctOptionIndex,
    };
  }
}

class QuizStepFormState extends StepTypeFormBaseState<QuizStepForm> {
  final List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _addQuestion(); // Start with one question
  }

  @override
  void dispose() {
    for (var question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  @override
  String get titlePlaceholder => 'e.g., Flutter Basics Quiz';

  @override
  String get descriptionPlaceholder => 'e.g., Test your knowledge of fundamental Flutter concepts';

  void _addQuestion() {
    setState(() {
      _questions.add(QuizQuestion());
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Question ${index + 1}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _removeQuestion(index),
                    color: Colors.red,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: question.questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                hintText: 'Enter your question...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ...List.generate(4, (optionIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Radio<int>(
                      value: optionIndex,
                      groupValue: question.correctOptionIndex,
                      onChanged: (value) {
                        setState(() {
                          question.correctOptionIndex = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: question.optionControllers[optionIndex],
                        decoration: InputDecoration(
                          labelText: 'Option ${optionIndex + 1}',
                          hintText: 'Enter option ${optionIndex + 1}...',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an option';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            const Text(
              'Select the radio button next to the correct answer',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildStepSpecificFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(_questions.length, (index) => _buildQuestionCard(index)),
        ElevatedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Add Question'),
        ),
      ],
    );
  }

  @override
  Map<String, dynamic> getStepSpecificFormData() {
    return {
      'questions': _questions.map((q) => q.toJson()).toList(),
    };
  }
}
