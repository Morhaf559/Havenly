/// ImageIdUploadModel represents the response from media upload endpoint
class ImageIdUploadModel {
  final int? id;

  ImageIdUploadModel({this.id});

  factory ImageIdUploadModel.fromJson(Map<String, dynamic> json) {
    return ImageIdUploadModel(id: json['id'] as int?);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
