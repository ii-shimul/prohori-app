class OutletHealth {
  const OutletHealth({
    required this.outletId,
    required this.dataQuality,
    required this.modelConfidence,
    required this.unusualActivityCount,
  });

  final String outletId;
  final String dataQuality;
  final double modelConfidence;
  final int unusualActivityCount;
}
