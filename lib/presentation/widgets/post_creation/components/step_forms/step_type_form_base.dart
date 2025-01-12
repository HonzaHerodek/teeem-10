import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../../data/models/step_type_model.dart';

class HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final side = math.min(w, h) / 2;
    final centerX = w / 2;
    final centerY = h / 2;

    // Calculate points for regular hexagon
    final points = List.generate(6, (i) {
      final angle = (i * 60 - 30) * math.pi / 180;
      return Offset(
        centerX + side * math.cos(angle),
        centerY + side * math.sin(angle),
      );
    });

    // Draw hexagon
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final side = math.min(w, h) / 2;
    final centerX = w / 2;
    final centerY = h / 2;

    // Calculate points for regular hexagon
    final points = List.generate(6, (i) {
      final angle = (i * 60 - 30) * math.pi / 180;
      return Offset(
        centerX + side * math.cos(angle),
        centerY + side * math.sin(angle),
      );
    });

    // Draw hexagon
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

abstract class StepTypeFormBase extends StatefulWidget {
  final StepTypeModel stepType;
  final VoidCallback onCancel;
  final Function(Map<String, dynamic>) onSave;

  const StepTypeFormBase({
    Key? key,
    required this.stepType,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);
}

abstract class StepTypeFormBaseState<T extends StepTypeFormBase>
    extends State<T> {
  @protected
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // To be implemented by each step type form
  String get titlePlaceholder;
  String get descriptionPlaceholder;

  // To be implemented by each step type form
  Widget buildStepSpecificFields();

  Map<String, dynamic> getFormData() {
    return {
      'title': titleController.text,
      'description': descriptionController.text,
      ...getStepSpecificFormData(),
    };
  }

  // To be implemented by each step type form
  Map<String, dynamic> getStepSpecificFormData();

  // To be implemented by each step type form to build additional options UI
  Widget buildMoreOptions() {
    // Default implementation returns an empty container
    // Subclasses can override this to provide their own UI
    return Container();
  }

  // State for More Options expansion
  @protected
  bool showMoreOptions = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final size = screenSize.width;
    final contentWidth = size * 0.85; // Slightly wider content area

    return Stack(children: [
      CustomPaint(
        painter: HexagonPainter(color: Colors.white),
        size: Size(size, screenSize.height),
      ),
      ClipPath(
          clipper: HexagonClipper(),
          child: SizedBox(
            width: size,
            height: screenSize.height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Stack(
                children: [
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Fixed header section
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Title field
                              Center(
                                child: SizedBox(
                                  width: contentWidth * 0.5,
                                  height: 40,
                                  child: TextFormField(
                                    controller: titleController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: titlePlaceholder,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    validator:
                                        null, // Title field is now optional
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Description field with reduced width
                              Center(
                                child: SizedBox(
                                  width: contentWidth,
                                  height: 60,
                                  child: TextFormField(
                                    controller: descriptionController,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: descriptionPlaceholder,
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                    ),
                                    validator:
                                        null, // Description field is now optional
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Main content area
                        if (showMoreOptions) ...[
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  buildStepSpecificFields(),
                                  const Divider(height: 16),
                                  buildMoreOptions(),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          SizedBox(
                            height: 140,
                            child: SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: buildStepSpecificFields(),
                            ),
                          ),
                        ],
                        // More options button
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => setState(() {
                              showMoreOptions = !showMoreOptions;
                            }),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  showMoreOptions
                                      ? 'Less Options'
                                      : 'More Options',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  showMoreOptions
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button overlay
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onCancel,
                    ),
                  ),
                ],
              ),
            ),
          ))
    ]);
  }
}
