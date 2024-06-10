// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartal/kartal.dart';
import 'package:listcom/bloc/theme/theme_state.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/extension/context_extension.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/helper/notification_helper.dart';
import 'package:listcom/model/shopping_list.dart';
import 'package:listcom/model/user.dart';
import 'package:listcom/view/shopping_list_detail_view.dart';
import 'package:listcom/bloc/theme/theme_cubit.dart';
import 'package:listcom/bloc/user/user_cubit.dart';
import 'package:listcom/widget/drawer.dart';
import 'package:lottie/lottie.dart';
import 'package:random_string/random_string.dart';

class ShoppingListsView extends StatefulWidget {
  const ShoppingListsView({super.key});

  @override
  _ShoppingListsViewState createState() => _ShoppingListsViewState();
}

class _ShoppingListsViewState extends State<ShoppingListsView> {
  List<ShoppingList>? lists;
  late DatabaseHelper dbHelper;

  @override
  void initState() {
    dbHelper = DatabaseHelper.instance;
    refreshLists();
    super.initState();
  }

  void refreshLists() async {
    // Tüm listeleri uygulamada çekmemiz için kullandığımız fonksiyon
    User user = BlocProvider.of<UserCubit>(context).state.user!;
    List<ShoppingList> listData = await dbHelper.getLists(user.id!);
    setState(() {
      lists = listData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(builder: (context, state) {
      return Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          elevation: 10,
          title: Text(
            context.translate.my_lists,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: lists == null
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : (lists!.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LottieBuilder.asset(AppConstants.add_list_animation),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(
                            context.translate.start_using_create_new_list,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        ...lists!.map<Widget>((list) => SizedBox(
                              height: context.sized.dynamicHeight(0.1),
                              child: Card(
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          onPressed: () async {
                                            final notificationHelper =
                                                NotificationHelper.instance;
                                            DateTime? date =
                                                await notificationHelper
                                                    .selectDateTime(context);
                                            if (date != null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(context
                                                          .translate
                                                          .alarm_setted)));

                                              await notificationHelper
                                                  .scheduleNotification(
                                                      date,
                                                      list.id!,
                                                      list.name,
                                                      context.translate
                                                          .notificarion_body_1);
                                            }
                                          },
                                          icon: const Icon(
                                              Icons.notification_add)),
                                      IconButton(
                                          onPressed: () {
                                            setState(() {
                                              dbHelper.deleteList(list.id!);
                                              refreshLists();
                                            });
                                          },
                                          icon: const Icon(Icons.delete))
                                    ],
                                  ),
                                  title: Text(
                                    list.name,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ShoppingListDetailView(
                                                  list: list),
                                        ));
                                  },
                                ),
                              ),
                            ))
                      ],
                    )),
        ),

        floatingActionButton: FloatingActionButton.extended(
          label: Text(context.translate.new_list),
          onPressed: () => _displayAddItemDialog(context),
          icon: const Icon(Icons.add),
        ),

        // Diğer UI bileşenleri ve işlevsellikler
      );
    });
  }

  _displayAddItemDialog(BuildContext context) async {
    // Yeni liste ekleme dialoğu
    TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.translate.new_list),
            content: TextField(
              controller: textFieldController,
              decoration:
                  InputDecoration(hintText: context.translate.enter_list_title),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(context.translate.cancel.toUpperCase()),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(context.translate.save.toUpperCase()),
                onPressed: () {
                  User? user = BlocProvider.of<UserCubit>(context).state.user;
                  String uniqueCode = randomAlphaNumeric(16);
                  ShoppingList list = ShoppingList(
                      name: textFieldController.text,
                      uniqueCode: uniqueCode,
                      userIdList: [user!.id!]);
                  setState(() {
                    dbHelper.insertList(list);
                    refreshLists();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
