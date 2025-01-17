// Firebase imports commented out for development
// import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/step_type_model.dart';
import '../../domain/repositories/step_type_repository.dart';

class FirebaseStepTypeRepository implements StepTypeRepository {
  // Firebase instance commented out for development
  // final FirebaseFirestore _firestore;

  FirebaseStepTypeRepository();

  @override
  Future<List<StepTypeModel>> getStepTypes() async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }

  @override
  Future<StepTypeModel> getStepTypeById(String id) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }

  @override
  Future<void> createStepType(StepTypeModel stepType) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }

  @override
  Future<void> updateStepType(StepTypeModel stepType) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }

  @override
  Future<void> deleteStepType(String id) async {
    // Mock implementation
    throw UnimplementedError('Using mock repository instead');
  }
}
