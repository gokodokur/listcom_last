import 'package:easy_autocomplete/easy_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/extension/context_extension.dart';
import 'package:listcom/helper/database_helper.dart';
import 'package:listcom/model/shopping_item.dart';
import 'package:listcom/model/shopping_list.dart';
import 'package:listcom/data/product_data.dart';
import 'package:lottie/lottie.dart';

class ShoppingListDetailView extends StatefulWidget {
  final ShoppingList list;
  const ShoppingListDetailView({super.key, required this.list});

  @override
  State<ShoppingListDetailView> createState() => _ShoppingListDetailViewState();
}

class _ShoppingListDetailViewState extends State<ShoppingListDetailView> {
  List<ShoppingItem>? items;

  late DatabaseHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper.instance;
    refreshItems();
  }

  void refreshItems() async {
    // Listenin içindeki itemleri çekiyor
    List<ShoppingItem> itemList = await dbHelper.getItems(widget.list.id!);
    setState(() {
      items = itemList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.list.name),
        actions: [
          IconButton(
              onPressed: () {
                _displayAddUserDialog(
                    context, widget.list); // Kullancıyla listeyi paylaşma
              },
              icon: const Icon(Icons.share))
        ],
      ),
      body: items == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : (items!.isEmpty // İlk ürününü eklemek için kullanıcıyı yönlendirme
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(AppConstants.add_item_animation),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      context.translate.detail_view_warning,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    )
                  ],
                )
              : ListView.builder(
                  // ürünleri listeleme
                  itemCount: items!.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(
                          items![index].title,
                          style: TextStyle(
                              decoration: items![index].isDone
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: items![index].isDone,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  items![index].isDone = newValue!;
                                  dbHelper.updateItem(items![index]);
                                });
                              },
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    dbHelper.deleteItem(items![index].id!);
                                    refreshItems();
                                  });
                                },
                                icon: const Icon(Icons.delete))
                          ],
                        ),
                        onLongPress: () {
                          dbHelper.deleteItem(items![index].id!);
                          refreshItems();
                        },
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(context.translate.new_item),
        onPressed: () => _displayAddItemDialog(context),
        icon: const Icon(Icons.add),
      ),
    );
  }

  _displayAddUserDialog(BuildContext context, ShoppingList list) async {
    // User ekleme dialogu
    final TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.translate.add_new_user),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(context.translate.enter_user_id),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: textFieldController,
                  decoration:
                      InputDecoration(hintText: context.translate.user_id),
                ),
              ],
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
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (int.tryParse(textFieldController.text) != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.translate.user_added)));

                    await dbHelper.insertUserToList(
                        list, int.parse(textFieldController.text));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(context.translate.invalid_user_id)));
                  }
                },
              ),
            ],
          );
        });
  }

  _displayAddItemDialog(BuildContext context) async {
    // Alınacak ürün ekleme dialogu
    final TextEditingController textFieldController = TextEditingController();
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(context.translate.new_item),
            content: EasyAutocomplete(
              suggestions: products,
              controller: textFieldController,
              decoration:
                  InputDecoration(hintText: context.translate.enter_item_title),
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
                  setState(() {
                    dbHelper.insertItem(ShoppingItem(
                        title: textFieldController.text,
                        listId: widget.list.id!,
                        isDone: false));
                    refreshItems();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
