<<<<<<< HEAD
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/dio_client.dart';
=======
// import '../../../../core/constants/api_constants.dart';
// import '../../../../core/services/dio_client.dart';
// import '../../domain/repositories/auth_repository.dart';

// class AuthRepositoryImpl implements AuthRepository {
//   @override
//   Future<String> verifyFirebaseToken(String firebaseToken) async {
//     final response = await DioClient.instance.post(
//       ApiConstants.verifyToken,
//       data: {'firebase_token': firebaseToken},
//     );
//     final data = response.data['data'] as Map<String, dynamic>;
//     return data['access_token'] as String;
//   }
// }

>>>>>>> 52b362492a0d4bb37457296bc8afd097bc83b256
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<String> verifyFirebaseToken(String firebaseToken) async {
<<<<<<< HEAD
    final response = await DioClient.instance.post(
      ApiConstants.verifyToken,
      data: {'firebase_token': firebaseToken},
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return data['access_token'] as String;
=======
    // Pura-pura loading 1 detik, lalu kembalikan token sukses!
    await Future.delayed(const Duration(seconds: 1));
    return "dummy_access_token_12345";
>>>>>>> 52b362492a0d4bb37457296bc8afd097bc83b256
  }
}