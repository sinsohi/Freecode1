import 'package:firebase_auth/firebase_auth.dart'; // Firebase 인증을 위한 패키지를 가져옵니다.
import 'package:flutter/material.dart'; // Flutter의 기본 패키지를 가져옵니다.
import 'auth.dart'; // auth.dart 파일을 가져옵니다. (사용자 정의 인증 관련 클래스)

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = ''; // 오류 메시지를 저장할 변수입니다.
  bool isLogin = true; // 현재 로그인 페이지인지 회원가입 페이지인지를 나타내는 변수

  final TextEditingController _controllerEmail =
      TextEditingController(); // 이메일 입력을 위한 텍스트 편집 컨트롤러
  final TextEditingController _controllerPassword =
      TextEditingController(); // 비밀번호 입력을 위한 텍스트 편집 컨트롤러

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      // 이메일과 비밀번호를 사용하여 Firebase 인증을 통해 로그인을 시도
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message; // 로그인 과정에서 발생한 오류 메시지를 저장
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
          email: _controllerEmail.text, password: _controllerPassword.text);
      // 이메일과 비밀번호를 사용하여 Firebase 인증을 통한 회원가입
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message; // 회원가입 과정에서 발생한 오류 메시지를 저장
      });
    }
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: title),
    );
    // 주어진 제목과 컨트롤러를 사용하여 텍스트 필드 위젯을 생성
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humn ? $errorMessage');
    // 오류 메시지를 표시하는 위젯. 오류 메시지가 없으면 표시되지 않음
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(isLogin ? 'Login' : 'Register'),
    );
    // 로그인 또는 회원가입 버튼을 생성하는 위젯. 버튼 텍스트는 isLogin 변수에 따라 결정됨.
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      },
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
    );
    // 로그인 페이지와 회원가입 페이지 전환을 위한 버튼을 생성하는 위젯.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
        child: Container(
          decoration: BoxDecoration(
              color: Color.fromRGBO(248, 246, 232, 1),
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.circle, size: 10),
                        Icon(Icons.circle, size: 10)
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color.fromRGBO(248, 246, 232, 1),
    );
  }
}

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
//         child: Container(
//           height: double.infinity,
//           width: double.infinity,
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               _entryField('email', _controllerEmail), // 이메일 입력 필드를 추가
//               _entryField('password', _controllerPassword), // 비밀번호 입력 필드를 추가
//               _errorMessage(), // 오류 메시지를 표시하는 위젯을 추가
//               _submitButton(), // 로그인 또는 회원가입 버튼을 추가
//               _loginOrRegisterButton(), // 페이지 전환 버튼을 추가
//             ],
//           ),
//         ),
//       ),
//       backgroundColor: Color.fromRGBO(255, 255, 255, 20),
//     );
//   }

