import '../datasources/courses_local_datasource.dart';
import '../models/course.dart';

class CoursesRepository {
  final CoursesLocalDatasource _datasource;

  CoursesRepository({CoursesLocalDatasource? datasource})
      : _datasource = datasource ?? const CoursesLocalDatasource();

  Future<List<Course>> getCourses() async {
    return await _datasource.loadCourses();
  }

  Future<Course?> getCourseById(String id) async {
    final courses = await getCourses();
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }
}
