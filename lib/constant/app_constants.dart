import 'package:flutter/material.dart';

class AppConstants {
  // Uygulamada kullanılan sabit değerli değişkenleri tuttuğumuz sınıf
  // Veri tabanı için sabitler
  static const id = "id";
  static const userIdList = "userIdList";
  static const name = "name";
  static const email = "email";
  static const passwordHash = "passwordHash";
  static const uniqueCode = "uniqueCode";
  static const listId = "listId";
  static const title = "title";
  static const isDone = "isDone";
  static const lists = "lists";
  static const users = "users";
  static const storedUser = "storedUser";
  static const listItems = "listItems";

  // Renk
  static const mainColor = Color(0xff0082fc);
  static const fireColor = Color(0xfffc8b00);
  static const jungleColor = Color(0xff4F6F52);
  static const beachColor = Color(0xff41C9E2);

  // password hash
  static const saltText = "9VpRvUWlZDEGbVEw";

  // Uygulama içi assetler
  static const logo = "assets/logo.png";
  static const add_list_animation = "assets/animations/add_list_animation.json";
  static const add_item_animation = "assets/animations/add_item_animation.json";
}
