import 'package:flutter/material.dart';
import 'package:listcom/bloc/user/user_state.dart';
import 'package:listcom/constant/app_constants.dart';
import 'package:listcom/extension/context_extension.dart';
import 'package:listcom/view/register_view.dart';
import 'package:listcom/view/shopping_lists_view.dart';
import 'package:listcom/bloc/user/user_cubit.dart';
import 'package:listcom/extension/validator_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartal/kartal.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final userCubit = BlocProvider.of<UserCubit>(context);

    // Textfield controllerları
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text(context.translate.login)),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoggedIn) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const ShoppingListsView()),
            );
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(
                      AppConstants.logo,
                      width: context.sized.dynamicWidth(0.4),
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value != null || value!.isNotEmpty) {
                          if (value.isValidEmail()) {
                            return null;
                          } else {
                            return context.translate.invalid_email_format;
                          }
                        } else {
                          return context.translate.please_enter_email;
                        }
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: context.translate.email,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) {
                        if (value != null || value!.isNotEmpty) {
                          if (value.isValidPassword()) {
                            return null;
                          } else {
                            return context.translate.invalid_password_format;
                          }
                        } else {
                          return context.translate.please_enter_password;
                        }
                      },
                      decoration: InputDecoration(
                        labelText: context.translate.password,
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      child: Text(context.translate.login),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          userCubit.login(
                              email: emailController.text,
                              password: passwordController.text);
                        }
                      },
                    ),
                    const SizedBox(height: 15),
                    TextButton(
                      child: Text(context.translate.dont_have_account),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RegisterView()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
