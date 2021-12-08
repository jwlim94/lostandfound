import 'package:flutter/material.dart';

class CustomDropDown extends StatefulWidget {
  Function(String) onSelectedParam;

  // callback function has been passed to get the type string back to upload.dart
  CustomDropDown({
    required this.onSelectedParam,
  });

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  String generalType = '';
  String specificType = '';
  bool generalTypeHasChanged = false;
  bool specificTypeHasChanged = false;
  bool disableDropdown = true;
  List<DropdownMenuItem<String>> menuItems = [];

  final electionics = {
    '1': 'Laptop',
    '2': 'Pad',
    '3': 'Phone',
  };

  final others = {
    '1': 'Water bottle',
    '2': 'Wallet',
    '3': 'ID card',
  };

  populateElectronics() {
    for (String key in electionics.keys) {
      menuItems.add(DropdownMenuItem<String>(
        value: electionics[key] as String,
        child: Center(
          child: Text(
            electionics[key] as String,
          ),
        ),
      ));
    }
  }

  populateOthers() {
    for (String key in others.keys) {
      menuItems.add(DropdownMenuItem<String>(
        value: others[key] as String,
        child: Center(
          child: Text(
            others[key] as String,
          ),
        ),
      ));
    }
  }

  generalTypeChanged(_value) {
    setState(() {
      menuItems.clear();
    });

    if (_value == 'Electronics') {
      populateElectronics();
    } else if (_value == 'Others') {
      populateOthers();
    }

    setState(() {
      generalType = _value;
      disableDropdown = false;
      generalTypeHasChanged = true;
      specificTypeHasChanged = false;
      specificType = '';
    });
  }

  specificTypeChanged(_value) {
    setState(() {
      specificType = _value;
      specificTypeHasChanged = true;

      // pass the specific type value back to upload.dart
      widget.onSelectedParam(_value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 30.0,
          child: DropdownButton<String>(
            menuMaxHeight: 300.0,
            items: const [
              DropdownMenuItem<String>(
                value: 'Electronics',
                child: Center(
                  child: Text('Electronics'),
                ),
              ),
              DropdownMenuItem<String>(
                value: 'Others',
                child: Center(
                  child: Text('Others'),
                ),
              ),
            ],
            onChanged: (_value) => generalTypeChanged(_value),
            hint: Text(
              generalTypeHasChanged ? generalType : 'What is the general type?',
            ),
            // to remove underline
            underline: const SizedBox(),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(
            bottom: 5.0,
          ),
        ),
        SizedBox(
          height: 30.0,
          child: DropdownButton<String>(
            menuMaxHeight: 300.0,
            items: menuItems,
            onChanged: disableDropdown
                ? null
                : (_value) => specificTypeChanged(_value),
            hint: Text(
              specificTypeHasChanged ? specificType : 'Choose a specific type',
            ),
            // to remove underline
            underline: const SizedBox(),
          ),
        ),
      ],
    );
  }
}
