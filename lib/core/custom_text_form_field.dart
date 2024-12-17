import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String labelText;
  final String? hintText;
  final bool obscureText;
  final void Function(String)? onChanged;

  const CustomTextFormField({
    super.key,
    this.controller,
    required this.labelText,
    this.hintText,
    this.obscureText = false,
    this.onChanged,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _passwordVisible = true;

  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _passwordVisible,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 0.26,
          ),
        ),
        suffixIcon: widget.obscureText
            ? GestureDetector(
                onTap: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  child: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
