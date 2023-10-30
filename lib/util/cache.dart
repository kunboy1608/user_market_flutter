import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:user_market/entity/user.dart';

class Cache {
  static String userId = "";
  static String cartId = "";
  static User? user;
  static UserCredential? userCredential;
}
