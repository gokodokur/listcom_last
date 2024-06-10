import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listcom/bloc/user/user_state.dart';
import 'package:listcom/extension/context_extension.dart';
import 'package:listcom/view/login_view.dart';
import 'package:listcom/bloc/user/user_cubit.dart';
import 'package:listcom/view/settings_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Center(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.user == null ? "none user" : state.user!.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            state.user == null
                                ? "null"
                                : "${context.translate.user_id}: ${state.user!.id.toString()}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(context.translate.settings),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const SettingsView();
                  }));
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: Text(context.translate.logout),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
                    ),
                  );

                  context.read<UserCubit>().clearUserData();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
