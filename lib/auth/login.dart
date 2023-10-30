import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:user_market/home/home.dart';
import 'package:user_market/service/entity/user_service.dart';
import 'package:user_market/service/google/firebase_service.dart';
import 'package:user_market/user/user_infor_editor.dart';
import 'package:user_market/util/cache.dart';
import 'package:user_market/util/const.dart';
import 'package:user_market/util/spm.dart';
import 'package:user_market/util/widget_util.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _formSignUpKey = GlobalKey<FormState>();
  final FocusNode _nodePassword = FocusNode();

  // Login controller
  final TextEditingController _usernameTEC = TextEditingController();
  final TextEditingController _passwordTEC = TextEditingController();

  // Sign up contrller
  final TextEditingController _emailTEC = TextEditingController();
  final TextEditingController _newPassTEC = TextEditingController();
  final TextEditingController _conPassTEC = TextEditingController();

  final FocusNode _nodeNewPass = FocusNode();
  final FocusNode _nodeConPass = FocusNode();

  int _status = 0;

  String _noti = "";
  String _notiSignUp = "";

  String? _checkEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter username";
    }
    final RegExp regex =
        RegExp(r'^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]');
    return regex.hasMatch(value) ? null : "Invalid email";
  }

  String? _checkPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter password";
    }

    if (value.length < 6) {
      return "Password leasts 6 chracters";
    }

    return null;
  }

  void _login() {
    _usernameTEC.text = _usernameTEC.text.trim();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    WidgetUtil.showLoadingDialog(context);

    FirebaseService.instance
        .signInWithEmail(_usernameTEC.text.trim(), _passwordTEC.text)
        .then((credential) {
      if (credential != null) {
        Cache.userCredential = credential;
        Cache.userId = credential.user!.uid;
        SPM.set(SPK.username, _usernameTEC.text.trim());
        SPM.set(SPK.password, _passwordTEC.text);
        UserService.instance.get().then((value) {
          if (value != null && value.isNotEmpty) {
            Cache.user = value.first;
          }
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ));
        });
      } else {
        Navigator.of(context).pop();
        setState(() {
          _noti = "Invalid user's information";
        });
      }
    });
  }

  Widget _loginButton(Size size) {
    return Positioned(
      left: defPading,
      right: size.width / 2 - (_status == 1 ? 4 * defPading : 0),
      bottom: _status == 0
          ? 10
          : _status == 1
              ? 300
              : 350,
      child: FilledButton(
        onPressed: () {
          setState(() {
            _status = 1;
          });
        },
        style: FilledButton.styleFrom(
            backgroundColor: _status == 1 ? Colors.red : null),
        child: const Text(
          "Login",
        ),
      ),
    );
  }

  Widget _signInButton(Size size) {
    return Positioned(
        left: size.width / 2 - (_status == 2 ? 4 * defPading : 0),
        right: defPading,
        bottom: _status == 0
            ? 10
            : _status == 1
                ? 300
                : 350,
        child: FilledButton(
          onPressed: () {
            setState(() {
              _status = 2;
            });
          },
          style: FilledButton.styleFrom(
              backgroundColor: _status == 2 ? Colors.red : null),
          child: const Text(
            "Sign up",
          ),
        ));
  }

  void _signUp() {
    if (!_formSignUpKey.currentState!.validate()) {
      return;
    }

    WidgetUtil.showLoadingDialog(context);

    FirebaseService.instance
        .createUser(_emailTEC.text.trim(), _newPassTEC.text)
        .then((credential) {
      Navigator.of(context).pop();

      if (credential != null) {
        Cache.userCredential = credential;
        Cache.userId = credential.user!.uid;
        SPM.set(SPK.username, _emailTEC.text.trim());
        SPM.set(SPK.password, _newPassTEC.text);
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const UserInforEditor(redirectToHome: true),
            ));
      } else {
        setState(() {
          _notiSignUp = "Unexpected errors";
        });
      }
    }).onError((error, stackTrace) {
      Navigator.of(context).pop();

      if (error is FirebaseAuthException) {
        setState(() {
          switch (error.code) {
            case "email-already-in-use":
              _notiSignUp =
                  "The email address is already in use by another account.";
              break;
            case "invalid-email":
              _notiSignUp = "Email address is invalid";
              break;
            case "weak-password":
              _notiSignUp = "Password is too weak";
              break;
            default:
              _notiSignUp = "Unexpected errors";
          }
        });
      } else {
        setState(() {
          _notiSignUp = "Unexpected errors";
        });
      }
    });
  }

  Widget _loginWidget() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(defPading),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(defRadius),
              topRight: Radius.circular(defRadius)),
          color: Theme.of(context).colorScheme.secondaryContainer),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Spacer(),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("Username"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defRadius)),
                prefixIcon: const Icon(Icons.person_2_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _usernameTEC.text = "",
                ),
              ),
              controller: _usernameTEC,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (value) => _checkEmail(value),
              onEditingComplete: () => _nodePassword.requestFocus(),
            ),
            const Spacer(),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("Password"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defRadius)),
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _passwordTEC.text = "",
                ),
              ),
              controller: _passwordTEC,
              focusNode: _nodePassword,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              validator: (value) => _checkPassword(value),
              onEditingComplete: _login,
            ),
            _noti.isEmpty
                ? const SizedBox(
                    height: defPading,
                  )
                : Text(
                    _noti,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _login, child: const Text("Login"))),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _signUpWidget() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(defPading),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(defRadius),
              topRight: Radius.circular(defRadius)),
          color: Theme.of(context).colorScheme.secondaryContainer),
      child: Form(
        key: _formSignUpKey,
        child: Column(
          children: [
            const Spacer(),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("Email"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defRadius)),
                prefixIcon: const Icon(Icons.person_2_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _emailTEC.text = "",
                ),
              ),
              controller: _emailTEC,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              validator: (value) => _checkEmail(value),
              onEditingComplete: () => _nodeNewPass.requestFocus(),
            ),
            const Spacer(),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("New password"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defRadius)),
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _newPassTEC.text = "",
                ),
              ),
              controller: _newPassTEC,
              focusNode: _nodeNewPass,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              validator: (value) => _checkPassword(value),
              onEditingComplete: () => _nodeConPass.requestFocus(),
            ),
            _noti.isEmpty
                ? const SizedBox(
                    height: defPading,
                  )
                : Text(
                    _noti,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
            const Spacer(),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("Confirm password"),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(defRadius)),
                prefixIcon: const Icon(Icons.lock_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () => _conPassTEC.text = "",
                ),
              ),
              controller: _conPassTEC,
              focusNode: _nodeConPass,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              validator: (value) {
                if (_conPassTEC.text != _newPassTEC.text) {
                  return "Confirm password is not the same new password";
                }
                return null;
              },
              onEditingComplete: _signUp,
            ),
            _notiSignUp.isEmpty
                ? const SizedBox(
                    height: defPading,
                  )
                : Text(
                    _notiSignUp,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
            const Spacer(),
            SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _signUp, child: const Text("Sign up"))),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  List<Widget> _groupButton(Size size) {
    if (_status == 2) {
      return [_loginButton(size), _signInButton(size)];
    }
    return [_signInButton(size), _loginButton(size)];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          setState(() {
            _status = 0;
          });
        },
        child: Stack(
          children: [
            Image.asset(
              "assets/img/background_login.png",
              width: size.width,
              height: size.height,
              fit: BoxFit.cover,
            ),
            ..._groupButton(size)
          ],
        ),
      ),
      bottomSheet: _status == 0
          ? null
          : _status == 1
              ? _loginWidget()
              : _signUpWidget(),
    );
  }

  @override
  void dispose() {
    _conPassTEC.dispose();
    _emailTEC.dispose();
    _newPassTEC.dispose();
    _nodePassword.dispose();
    _passwordTEC.dispose();
    _usernameTEC.dispose();
    _nodeConPass.dispose();
    _nodeNewPass.dispose();
    super.dispose();
  }
}
