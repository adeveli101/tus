import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tus/features/tus_scores/domain/models/department_model.dart';
import 'package:tus/features/tus_scores/domain/models/department_score_model.dart';
import 'package:tus/features/tus_scores/domain/models/exam_period_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  final CollectionReference _examPeriodsCollection = FirebaseFirestore.instance.collection('tus_exam_periods');
  final CollectionReference _departmentsCollection = FirebaseFirestore.instance.collection('departments');
  final CollectionReference _departmentScoresCollection = FirebaseFirestore.instance.collection('department_scores');

  // Auth methods
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Giriş yapılamadı: $e');
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Kayıt olunamadı: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Çıkış yapılamadı: $e');
    }
  }

  // Firestore methods
  Future<void> addUserData(String userId, Map<String, dynamic> userData) async {
    try {
      await _firestore.collection('users').doc(userId).set(userData);
    } catch (e) {
      throw Exception('Kullanıcı verisi eklenemedi: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Kullanıcı verisi alınamadı: $e');
    }
  }

  Future<void> createUserDocument(User user, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserDocument(String userId) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .get();
  }

  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .update(data);
  }

  // Questions methods
  Stream<QuerySnapshot> getQuestions({int? limit}) {
    Query<Map<String, dynamic>> query = _firestore.collection('questions');
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  // Subjects methods
  Stream<QuerySnapshot> getSubjects() {
    return _firestore.collection('subjects').snapshots();
  }

  // Progress methods
  Future<void> updateProgress(String userId, Map<String, dynamic> progress) async {
    await _firestore
        .collection('progress')
        .doc(userId)
        .set(progress, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getUserProgress(String userId) {
    return _firestore
        .collection('progress')
        .doc(userId)
        .snapshots();
  }

  // TUS Scores methods
  Future<List<Map<String, dynamic>>> getTusScores({
    String? year,
    String? term,
    String? city,
    String? university,
    String? department,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('departmentScoreRankings');
      
      if (year != null) {
        query = query.where('year', isEqualTo: year);
      }
      if (term != null) {
        query = query.where('term', isEqualTo: term);
      }
      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }
      if (university != null) {
        query = query.where('university', isEqualTo: university);
      }
      if (department != null) {
        query = query.where('department', isEqualTo: department);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('TUS puanları alınamadı: $e');
    }
  }

  // Preference List methods
  Future<void> savePreferenceList(String userId, String listId, List<Map<String, dynamic>> preferences) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferenceLists')
          .doc(listId)
          .set({
        'preferences': preferences,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Tercih listesi kaydedilemedi: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getPreferenceLists(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('preferenceLists')
          .get();
      
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Tercih listeleri alınamadı: $e');
    }
  }

  // Department Preference Stats methods
  Future<Map<String, dynamic>?> getDepartmentPreferenceStats(String departmentId) async {
    try {
      final doc = await _firestore
          .collection('departmentPreferenceStats')
          .doc(departmentId)
          .get();
      
      return doc.data();
    } catch (e) {
      throw Exception('Bölüm tercih istatistikleri alınamadı: $e');
    }
  }

  // Exam Period methods
  Future<List<ExamPeriodModel>> getExamPeriods() async {
    try {
      final querySnapshot = await _examPeriodsCollection
          .orderBy('year', descending: true)
          .orderBy('term')
          .get();
      
      return querySnapshot.docs
          .map((doc) => ExamPeriodModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Sınav dönemleri alınamadı: $e');
    }
  }

  // Department methods
  Future<List<DepartmentModel>> getDepartments({
    String? city,
    String? university,
    String? faculty,
  }) async {
    try {
      Query query = _departmentsCollection;
      
      if (city != null) {
        query = query.where('city', isEqualTo: city);
      }
      if (university != null) {
        query = query.where('universityName', isEqualTo: university);
      }
      if (faculty != null) {
        query = query.where('faculty', isEqualTo: faculty);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => DepartmentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Bölümler alınamadı: $e');
    }
  }

  // Department Score methods
  Future<List<DepartmentScoreModel>> getDepartmentScores({
    String? examPeriodId,
    String? departmentId,
    String? scoreType,
  }) async {
    try {
      Query query = _departmentScoresCollection;
      
      if (examPeriodId != null) {
        query = query.where('examPeriodId', isEqualTo: examPeriodId);
      }
      if (departmentId != null) {
        query = query.where('departmentId', isEqualTo: departmentId);
      }
      if (scoreType != null) {
        query = query.where('scoreType', isEqualTo: scoreType);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => DepartmentScoreModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Bölüm puanları alınamadı: $e');
    }
  }

  // Admin methods for manual data entry
  Future<void> addExamPeriod(ExamPeriodModel examPeriod) async {
    try {
      await _examPeriodsCollection.doc(examPeriod.id).set(examPeriod.toFirestore());
    } catch (e) {
      throw Exception('Sınav dönemi eklenemedi: $e');
    }
  }

  Future<void> addDepartment(DepartmentModel department) async {
    try {
      await _departmentsCollection.doc(department.id).set(department.toFirestore());
    } catch (e) {
      throw Exception('Bölüm eklenemedi: $e');
    }
  }

  Future<void> addDepartmentScore(DepartmentScoreModel score) async {
    try {
      await _departmentScoresCollection.doc(score.id).set(score.toFirestore());
    } catch (e) {
      throw Exception('Bölüm puanı eklenemedi: $e');
    }
  }
} 