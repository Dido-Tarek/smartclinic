class SearchDoctorsRequestModel {
  final String? query;
  final String? specialization;
  final String? city;
  final String? area;
  final int? consultationType;
  final int? maxPrice;
  final int pageNumber;
  final int pageSize;

  const SearchDoctorsRequestModel({
    this.query,
    this.specialization,
    this.city,
    this.area,
    this.consultationType,
    this.maxPrice,
    this.pageNumber = 1,
    this.pageSize = 10,
  });

  Map<String, dynamic> toJson() => {
    if (query != null) 'query': query,
    if (specialization != null) 'specialization': specialization,
    if (city != null) 'city': city,
    if (area != null) 'area': area,
    if (consultationType != null) 'consultationType': consultationType,
    if (maxPrice != null) 'maxPrice': maxPrice,
    'pageNumber': pageNumber,
    'pageSize': pageSize,
  };
}
