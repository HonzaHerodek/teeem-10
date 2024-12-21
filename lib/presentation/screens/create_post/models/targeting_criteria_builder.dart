import '../../../../data/models/targeting_model.dart';

class TargetingCriteriaBuilder {
  static TargetingCriteria? build({
    required String interests,
    required String locations,
    required String languages,
    required String skills,
    required String industries,
    required String minAge,
    required String maxAge,
    String? experienceLevel,
  }) {
    final interestsList = _parseCommaSeparatedList(interests);
    final locationsList = _parseCommaSeparatedList(locations);
    final languagesList = _parseCommaSeparatedList(languages);
    final skillsList = _parseCommaSeparatedList(skills);
    final industriesList = _parseCommaSeparatedList(industries);
    final minAgeValue = _parseIntOrNull(minAge);
    final maxAgeValue = _parseIntOrNull(maxAge);

    if (interestsList == null &&
        locationsList == null &&
        languagesList == null &&
        skillsList == null &&
        industriesList == null &&
        minAgeValue == null &&
        maxAgeValue == null &&
        experienceLevel == null) {
      return null;
    }

    return TargetingCriteria(
      interests: interestsList,
      minAge: minAgeValue,
      maxAge: maxAgeValue,
      locations: locationsList,
      languages: languagesList,
      experienceLevel: experienceLevel,
      skills: skillsList,
      industries: industriesList,
    );
  }

  static List<String>? _parseCommaSeparatedList(String value) {
    if (value.isEmpty) return null;
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static int? _parseIntOrNull(String value) {
    if (value.isEmpty) return null;
    return int.tryParse(value);
  }
}
