import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class CoursesLocalDatasource {
  final String jsonPath;

  const CoursesLocalDatasource({
    this.jsonPath = 'assets/data/courses.json',
  });

  Future<List<Course>> loadCourses() async {
    try {
      final jsonString = await rootBundle.loadString(jsonPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is! List) {
        throw const FormatException('Courses JSON must be a list');
      }

      return decoded
          .map((item) => Course.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load courses data: $e');
    }
  }
}
