import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listcom/bloc/user/user_state.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/model/user.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserCubit extends Cubit<UserState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  UserCubit() : super(UserInitial());

  void register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(UserLoading());

    final preferences = await SharedPreferences.getInstance();

    if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
      if ((await _dbHelper.getUserByEmail(email)) == null) {
        final user = User(
          id: int.parse(randomNumeric(4)),
          email: email,
          passwordHash: hashPassword(password),
          name: name,
        );

        await _dbHelper.insertUser(user);
        preferences.setString(AppConstants.storedUser, user.toJson());

        emit(UserRegistered(user));
      } else {
        emit(UserError("Bu mail adresi zaten uygulamaya kayıtlı"));
      }
    } else {
      emit(UserError("Lütfen tüm alanları eksiksiz doldurunuz"));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    emit(UserLoading());

    final preferences = await SharedPreferences.getInstance();

    User? newUser = await _dbHelper.getUserByEmail(email);

    if (email.isNotEmpty && password.isNotEmpty) {
      if (newUser != null) {
        if (checkPassword(password, newUser.passwordHash)) {
          preferences.setString(AppConstants.storedUser, newUser.toJson());

          emit(UserLoggedIn(newUser));
        } else {
          emit(UserError("Şifre hatalı. Lütfen şifrenizi kontrol ediniz"));
        }
      } else {
        emit(UserError("Bu mail adresine ait kullanıcı bulunamadı"));
      }
    } else {
      emit(UserError("Lütfen tüm alanları eksiksiz doldurun"));
    }
  }

  void clearUserData() async { // Clear the user data from shared preferences.
    final preferences = await SharedPreferences.getInstance();
    preferences.remove(AppConstants.storedUser);

    emit(UserLoggedOut());
  }

  void initStoredUser() async { // Get the user data from shared preferences.
    final preferences = await SharedPreferences.getInstance();
    String? userData = preferences.getString(AppConstants.storedUser);

    if (userData != null) {
      final user = User.fromJson(userData);

      emit(UserLoggedIn(user));
    }
  }

  String hashPassword(String input) =>
      hex.encode(md5.convert(utf8.encode(input + AppConstants.saltText)).bytes);

  bool checkPassword(String input, String passwordHash) =>
      passwordHash == hashPassword(input);
}

