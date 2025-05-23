import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreditCardInput extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final void Function(String)? onChanged;
  final FocusNode? focusNode;
  final FocusNode? nextFocusNode;
  final int maxLength;
  final String isNumber;
  final TextInputType type;

  const CreditCardInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.onChanged,
    this.focusNode,
    this.nextFocusNode,
    required this.maxLength,
    required this.type,
    required this.isNumber,
  });

  @override
  State<CreditCardInput> createState() => _CreditCardInputState();
}

class _CreditCardInputState extends State<CreditCardInput> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        if (widget.nextFocusNode != null &&
            value.replaceAll(' ', '').length == widget.maxLength) {
          FocusScope.of(context).requestFocus(widget.nextFocusNode);
        }
      },
      inputFormatters:
          widget.isNumber == 'name'
              ? [FilteringTextInputFormatter.allow(RegExp('[a-zA-Z ]'))]
              :
              // Don't apply any input formatter
              [
                /*if (widget.isNumber == 'number' ||
                    widget.isNumber == 'expiry' &&
                        widget.type == TextInputType.number)*/
                FilteringTextInputFormatter.digitsOnly,
                // allow only  digits
                if (widget.isNumber == 'number') CreditCardNumberFormatter(),
                if (widget.isNumber == 'expiry') ExpiryDateFormatter(),
                // custom class to format entered data from textField
                LengthLimitingTextInputFormatter(widget.maxLength),

                // restrict user to enter max 16 characters
              ],
      keyboardType: widget.type,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: Icon(Icons.credit_card, color: Colors.white),
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

abstract class CardInputFormatter extends TextInputFormatter {
  const CardInputFormatter();
}

class CreditCardNumberFormatter extends CardInputFormatter {
  const CreditCardNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    String enteredData = newValue.text; // get data enter by used in textField
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < enteredData.length; i++) {
      // add each character into String buffer
      buffer.write(enteredData[i]);
      int index = i + 1;
      if (index % 4 == 0 && enteredData.length != index) {
        // add space after 4th digit
        buffer.write(" ");
      }
    }

    return TextEditingValue(
      text: buffer.toString(), // final generated credit card number
      selection: TextSelection.collapsed(
        offset: buffer.toString().length,
      ), // keep the cursor at end
    );
  }
}

class ExpiryDateFormatter extends CardInputFormatter {
  const ExpiryDateFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String value = newValue.text.replaceAll('/', '');
    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < value.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(value[i]);
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
