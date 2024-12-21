import 'package:flutter/material.dart';

class PostCreationFirstPage extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isLoading;
  final VoidCallback onAddStep;
  final List<Widget> steps;
  final PageController pageController;

  const PostCreationFirstPage({
    Key? key,
    required this.titleController,
    required this.descriptionController,
    required this.isLoading,
    required this.onAddStep,
    required this.steps,
    required this.pageController,
  }) : super(key: key);

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    String? label,
    bool isLarger = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLarger
                  ? Colors.red.withOpacity(0.5)
                  : Colors.blue.withOpacity(0.5),
              border: Border.all(
                color: Colors.white.withOpacity(0.6),
                width: 1,
              ),
            ),
            child: Padding(
              padding: isLarger
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(12),
              child: Icon(icon, color: Colors.white, size: isLarger ? 28 : 24),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 40),
            TextFormField(
              controller: titleController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'Title of Task',
                hintStyle: TextStyle(color: Colors.white30),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descriptionController,
              enabled: !isLoading,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                hintText: 'short summary of the goal',
                hintStyle: TextStyle(color: Colors.white30),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(200),
                bottomRight: Radius.circular(200),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.settings,
                  onPressed: () {
                    // TODO: Implement settings action
                  },
                  label: 'Settings',
                ),
                _buildActionButton(
                  icon: Icons.auto_awesome,
                  onPressed: () {
                    // TODO: Implement AI action
                  },
                  label: 'AI',
                  isLarger: true,
                ),
                _buildActionButton(
                  icon: steps.isEmpty
                      ? Icons.add_circle
                      : Icons.format_list_numbered,
                  onPressed: steps.isEmpty
                      ? onAddStep
                      : () {
                          if (steps.isNotEmpty) {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                  label: steps.isEmpty ? 'Add Step' : 'Steps',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
