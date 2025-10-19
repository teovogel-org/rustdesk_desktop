import 'package:flutter/material.dart';
import 'package:flutter_hbb/kvm/constants.dart';
import 'package:flutter_hbb/kvm/domain/kvm_state_provider.dart';
import 'package:provider/provider.dart';

class KVMLoginPage extends StatefulWidget {
  const KVMLoginPage({super.key});

  @override
  State<KVMLoginPage> createState() => _KVMLoginPageState();
}

class _KVMLoginPageState extends State<KVMLoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? signInError;

  bool isLogingIn = false;

  var passwordVisible = false;

  @override
  void initState() {
    usernameController.text = prefilledEmail ?? "";
    passwordController.text = prefilledPass ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        elevation: 0,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        "Iniciar Sesión",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: "Usuario",
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value ==
                                  null /* ||
                                IRemoteAuth.validateEmailAddress(value.trim())*/
                              ) {
                            return "error";
                          }
                          return null;
                        },
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 16.0),
                          TextFormField(
                            obscureText: !passwordVisible,
                            controller: passwordController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "error";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                labelText: "Contraseña",
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _loginPressed();
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("Ingresar"),
                              if (isLogingIn)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      )),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (signInError != null)
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                signInError!,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _loginPressed() async {
    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    setState(() {
      isLogingIn = true;
    });

    await context
        .read<KVMStateProvider>()
        .login(username, password)
        .catchError((error) {
      displayErrorSnackbar(error.toString(), context);
    });

    setState(() {
      isLogingIn = false;
    });
  }

  void displayErrorSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
