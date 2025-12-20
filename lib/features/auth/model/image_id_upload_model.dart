class ImageIdUploadModel {
  int? id;

  ImageIdUploadModel({required this.id});

  factory ImageIdUploadModel.fromJson(Map<String, dynamic> json) {
    return ImageIdUploadModel(id: json['id']);
  }
}
