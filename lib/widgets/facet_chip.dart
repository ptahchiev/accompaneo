
import 'package:flutter/material.dart';

abstract class FacetChip extends StatelessWidget {

  final bool selected;

  final String facetValueCode;

  final String facetValueName;

  final int? facetValueCount;

  final bool? showCheckmark;

  final ValueChanged<bool>? onSelected;

  final VoidCallback? onDeleted;

  const FacetChip({
    super.key,
    required this.selected,
    required this.facetValueCode,
    required this.facetValueName,
    this.showCheckmark,
    this.facetValueCount,
    this.onSelected,
    this.onDeleted
  });


  @override
  Widget build(BuildContext context) {
    return InputChip(
      isEnabled: true,
      selected: selected,
      avatar: getAvatar(),
      label: getLabel(),
      showCheckmark: showCheckmark,
      checkmarkColor: Colors.white,
      side: BorderSide(color: selected ? Colors.grey : Colors.grey.shade400),
      onSelected: onSelected,
      onDeleted: onDeleted
    );
  }

  Widget? getAvatar();

  Widget getLabel();
}