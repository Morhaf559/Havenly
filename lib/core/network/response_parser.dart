import 'package:my_havenly_application/core/models/api_response.dart';

class ResponseParser {
  static List<T> parseList<T>({
    required dynamic responseData,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    List<dynamic> dataList;

    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        if (responseData['data'] is List) {
          dataList = responseData['data'] as List<dynamic>;
        } else {
          return [];
        }
      } else {
        return [];
      }
    } else if (responseData is List) {
      dataList = responseData;
    } else {
      return [];
    }

    return dataList
        .map((item) {
          try {
            if (item is Map<String, dynamic>) {
              return fromJson(item);
            }
            return null;
          } catch (e) {
            print('Error parsing item: $e');
            return null;
          }
        })
        .where((item) => item != null)
        .cast<T>()
        .toList();
  }

  static T? parseSingle<T>({
    required dynamic responseData,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    Map<String, dynamic> dataMap;

    if (responseData is Map<String, dynamic>) {
      if (responseData['data'] != null) {
        if (responseData['data'] is List) {
          // If data is a list, take the first element
          final dataList = responseData['data'] as List;
          if (dataList.isNotEmpty && dataList[0] is Map<String, dynamic>) {
            dataMap = dataList[0] as Map<String, dynamic>;
          } else {
            return null;
          }
        } else if (responseData['data'] is Map) {
          dataMap = responseData['data'] as Map<String, dynamic>;
        } else {
          dataMap = responseData;
        }
      } else {
        dataMap = responseData;
      }
    } else {
      return null;
    }

    try {
      return fromJson(dataMap);
    } catch (e) {
      print('Error parsing single object: $e');
      return null;
    }
  }

  static ApiResponse<T> parsePaginated<T>({
    required dynamic responseData,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    Map<String, dynamic> jsonMap;

    if (responseData is Map<String, dynamic>) {
      jsonMap = responseData;
    } else {
      jsonMap = {
        'data': responseData,
        'page': 0,
        'perPage': 15,
        'lastPage': 1,
        'total': responseData is List ? responseData.length : 0,
      };
    }

    return ApiResponse.fromJson(jsonMap, fromJson);
  }

  static Map<String, int> extractPagination(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return {'page': 0, 'perPage': 15, 'lastPage': 1, 'total': 0};
    }

    return {
      'page': responseData['page'] as int? ?? 0,
      'perPage':
          responseData['perPage'] as int? ??
          responseData['per_page'] as int? ??
          15,
      'lastPage':
          responseData['lastPage'] as int? ??
          responseData['last_page'] as int? ??
          1,
      'total': responseData['total'] as int? ?? 0,
    };
  }

  static bool hasDataWrapper(dynamic responseData) {
    return responseData is Map<String, dynamic> &&
        responseData.containsKey('data');
  }

  static dynamic extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      return responseData['data'];
    }
    return responseData;
  }
}
