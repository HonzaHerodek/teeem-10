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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (_questions.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    onPressed: () => _removeQuestion(index),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: Colors.red[300],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: question.questionController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter your question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a question';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            ...List.generate(4, (optionIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
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
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Option ${optionIndex + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
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
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                '✓ Select the correct answer',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
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
        OutlinedButton.icon(
          onPressed: _addQuestion,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Question', style: TextStyle(fontSize: 14)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            side: BorderSide(color: Colors.grey.withOpacity(0.5)),
          ),
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
