
import 'package:accompaneo/values/app_colors.dart';
import 'package:accompaneo/widgets/facet_chip.dart';
import 'package:flutter/material.dart';

class RangeChip extends FacetChip {

  const RangeChip({
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
}