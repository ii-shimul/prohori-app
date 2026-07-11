class ForecastPoint {
  const ForecastPoint({
    required this.riskBand,
    required this.likelyDepletionEtaMinutes,
  });

  final String riskBand;
  final int? likelyDepletionEtaMinutes;
}

class ForecastResource {
  const ForecastResource({
    required this.resource,
    required this.providerId,
    required this.points,
  });

  final String resource;
  final String? providerId;
  final List<ForecastPoint> points;
}

class OutletForecast {
  const OutletForecast({
    required this.outletId,
    required this.dataQuality,
    required this.modelConfidence,
    required this.limitingResource,
    required this.resources,
  });

  final String outletId;
  final String dataQuality;
  final double modelConfidence;
  final ForecastResource? limitingResource;
  final List<ForecastResource> resources;
}
