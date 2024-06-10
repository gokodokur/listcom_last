// ignore_for_file: overridden_fields

import 'package:listcom/model/user.dart';

abstract class UserState {
  final User? user;

  UserState({this.user});
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserRegistered extends UserState {
  @override
  final User user;

  UserRegistered(this.user);
}

class UserLoggedIn extends UserState {
  @override
  final User user;

  UserLoggedIn(this.user);
}

class UserLoggedOut extends UserState {}

class UserError extends UserState {
  final String errorMessage;

  UserError(this.errorMessage);
}
