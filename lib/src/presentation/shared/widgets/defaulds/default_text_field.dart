import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  String label;
  String? initialValue;
  IconData icon;
  EdgeInsetsGeometry margin;
  Color backgroundColor;
  String? errorText;
  Function(String text) onChanged;
  String? Function(String?)? validator;
  bool obscureText;

  DefaultTextField({
    super.key,
    required this.label,
    required this.icon,
    this.margin = const EdgeInsets.only(top: 50, left: 20, right: 20),
    required this.onChanged,
    this.backgroundColor = Colors.white,
    this.errorText,
    this.validator,
    this.initialValue,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: TextFormField(
        onChanged: (text) {
          onChanged(text);
        },
        initialValue: initialValue,
        decoration: InputDecoration(
          label: Text(label),
          border: InputBorder.none,
          prefixIcon: Container(
            margin: EdgeInsets.only(top: 10),
            child: Wrap(
              alignment: WrapAlignment.spaceEvenly,
              children: [
                Icon(icon),
                Container(height: 20, width: 1, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
      // child: TextFormField(
      //   obscureText: obscureText,
      //   onChanged: (text) {
      //     onChanged(text);
      //   },
      //   validator: validator,
      //   decoration: InputDecoration(
      //     label: Text(label, style: TextStyle(color: Colors.white)),
      //     errorText: errorText,
      //     prefixIcon: Icon(icon, color: Colors.white),
      //     enabledBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //     focusedBorder: UnderlineInputBorder(
      //       borderSide: BorderSide(color: Colors.white),
      //     ),
      //   ),
      //   style: TextStyle(color: Colors.white),
      // ),
    );
  }
}
