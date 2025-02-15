
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/widgets/facet_chip.dart';
import 'package:flutter/material.dart';

class GenreChip extends FacetChip {

  const GenreChip({
    super.key,
    required super.selected,
    required super.facetValueCode,
    required super.facetValueName,
    super.showCheckmark,
    super.facetValueCount,
    super.onSelected,
    super.onDeleted
  });

  @override
  Widget? getAvatar() {
    return selected ? CircleAvatar(backgroundColor: AppColors.primaryColor) : Container();
  }

  @override
  Widget getLabel() {
    return facetValueCount != null ? Text('$facetValueName ($facetValueCount)') : Text(facetValueName);
  }


  // @override
  // Widget build(BuildContext context) {
  //     return InputChip(
  //       isEnabled: true,
  //       avatar: selected ? CircleAvatar(backgroundColor: AppColors.primaryColor) : Container(), 
  //       label: facetValueCount != null ? Text('$facetValueName ($facetValueCount)') : Text(facetValueName),
  //       selected: selected,
  //       showCheckmark: true,
  //       //color: selected ? Colors.grey : Colors.black,
  //       checkmarkColor: Colors.white,
  //       side: BorderSide(color: selected ? Colors.grey : Colors.grey.shade400),
  //       onSelected: onSelected,
  //       onDeleted: onDeleted,

  //     );
  // }
}