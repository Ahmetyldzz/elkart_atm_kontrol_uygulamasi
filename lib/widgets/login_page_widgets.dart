import 'package:atm_kontrol_sistemi/constants/web_url.dart';
import 'package:flutter/material.dart';
import 'package:atm_kontrol_sistemi/constants/colors.dart';
import 'package:atm_kontrol_sistemi/constants/project_sizes.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.title,
      this.mainAxisAlignment});

  final void Function() onPressed;
  final String title;
  final MainAxisAlignment? mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
      ],
    );
  }
}

class LoginPageLogo extends StatelessWidget {
  const LoginPageLogo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
            width: 125,
            height: 85,
            child: Image.asset(
              ImagePaths.goraImage,
            )),
      ],
    );
  }
}

class CustomTextWidget extends StatelessWidget {
  const CustomTextWidget({
    super.key,
    required this.text,
    this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
    );
  }
}

class LoginPageLineDecor extends StatelessWidget {
  const LoginPageLineDecor({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.2,
      height: MediaQuery.sizeOf(context).height * 0.0065,
      color: ProjectColors.darkTheme,
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.isObscure,
    required this.iconData,
    required this.hinText,
    this.textEditingController, this.textInputAction,
  });

  final bool isObscure;
  final IconData iconData;
  final String hinText;
  final TextEditingController? textEditingController;
  final TextInputAction? textInputAction;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        color: Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(BorderRadiusSizes.highRadius),
      ),
      child: TextField(
        textInputAction: textInputAction ,
        controller: textEditingController,
        obscureText: isObscure,
        decoration: InputDecoration(
            hintText: hinText,
            border: InputBorder.none,
            prefixIcon: Icon(
              iconData,
              color: ProjectColors.darkTheme,
            )),
      ),
    );
  }
}
