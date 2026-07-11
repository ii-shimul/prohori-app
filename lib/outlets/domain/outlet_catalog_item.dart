class OutletArea {
  const OutletArea({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
  });

  final String id;
  final String code;
  final String name;
  final String? parentId;
}

class OutletCatalogItem {
  const OutletCatalogItem({
    required this.id,
    required this.code,
    required this.name,
    required this.area,
    required this.tier,
    required this.timezone,
    required this.status,
  });

  final String id;
  final String code;
  final String name;
  final OutletArea area;
  final int tier;
  final String timezone;
  final String status;
}
