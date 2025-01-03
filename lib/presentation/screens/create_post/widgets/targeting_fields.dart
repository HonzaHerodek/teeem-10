import 'package:flutter/material.dart';

class TargetingFields extends StatelessWidget {
  final TextEditingController interestsController;
  final TextEditingController minAgeController;
  final TextEditingController maxAgeController;
  final TextEditingController locationsController;
  final TextEditingController languagesController;
  final TextEditingController skillsController;
  final TextEditingController industriesController;
  final String? selectedExperienceLevel;
  final Function(String?) onExperienceLevelChanged;
  final bool enabled;

  const TargetingFields({
    super.key,
    required this.interestsController,
    required this.minAgeController,
    required this.maxAgeController,
    required this.locationsController,
    required this.languagesController,
    required this.skillsController,
    required this.industriesController,
    this.selectedExperienceLevel,
    required this.onExperienceLevelChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Targeting Criteria',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: interestsController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'Interests',
                  hintText: 'Enter interests separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minAgeController,
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: maxAgeController,
                      enabled: enabled,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Age',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: locationsController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'Locations',
                  hintText: 'Enter locations separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: languagesController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'Languages',
                  hintText: 'Enter languages separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedExperienceLevel,
                decoration: const InputDecoration(
                  labelText: 'Experience Level',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                      value: 'intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                  DropdownMenuItem(value: 'expert', child: Text('Expert')),
                ],
                onChanged: enabled ? onExperienceLevelChanged : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: skillsController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'Skills',
                  hintText: 'Enter skills separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: industriesController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'Industries',
                  hintText: 'Enter industries separated by commas',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
