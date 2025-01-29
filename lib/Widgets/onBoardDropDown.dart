import 'package:classinsight/models/SchoolModel.dart';
import 'package:classinsight/utils/fontStyles.dart';
import 'package:flutter/material.dart';

class OnBoardDropDown extends StatefulWidget {
  final List<School> items;
  final Function(School?)? onChanged;

  const OnBoardDropDown({
    Key? key,
    required this.items,
    this.onChanged,
  }) : super(key: key);

  @override
  _OnBoardDropDownState createState() => _OnBoardDropDownState();
}

class _OnBoardDropDownState extends State<OnBoardDropDown> {
  String? _selectedItemId;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: screenWidth * 0.65,
      height: screenHeight * 0.055,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedItemId,
            icon: Icon(Icons.arrow_drop_down, color: Colors.black),
            iconSize: screenHeight * 0.03,
            elevation: 16,
            style: Font_Styles.labelHeadingLight(context),
            hint: Text(
              'Select',
              style: TextStyle(color: Colors.black),
            ),
            items: widget.items
                .map((item) => DropdownMenuItem<String>(
                      value: item.schoolId, // Use schoolId as the value
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(item.name, style: TextStyle(color: Colors.black)),
                      ),
                    ))
                .toList(),
            onChanged: (selectedItemId) {
              setState(() {
                _selectedItemId = selectedItemId;
              });
              if (widget.onChanged != null) {
                // Find the School object based on selectedItemId
                School? selectedItem = widget.items.firstWhere(
                  (school) => school.schoolId == selectedItemId,
                );
                widget.onChanged!(selectedItem);
              }
            },
          ),
        ),
      ),
    );
  }
}
