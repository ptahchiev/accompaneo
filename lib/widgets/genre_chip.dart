
import 'package:accompaneo/values/app_colors.dart';
import 'package:flutter/material.dart';

class GenreChip extends StatelessWidget {

  final bool selected;

  final String facetValueName;

  final ValueChanged<bool>? onSelected;

  final VoidCallback? onDeleted;

  const GenreChip({
    super.key,
    required this.selected,
    required this.facetValueName,
    this.onSelected,
    this.onDeleted
  });


  @override
  Widget build(BuildContext context) {
      return InputChip(
        isEnabled: true,
        avatar: selected ? CircleAvatar(backgroundColor: AppColors.primaryColor) : Container(), 
        label: Text(facetValueName),
        selected: selected,
        showCheckmark: true,
        //color: selected ? Colors.grey : Colors.black,
        checkmarkColor: Colors.white,
        side: BorderSide(color: selected ? Colors.grey : Colors.grey.shade400),
        onSelected: onSelected,
        onDeleted: onDeleted,

      );
  }
}