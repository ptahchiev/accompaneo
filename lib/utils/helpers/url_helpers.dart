
class UrlHelper {

  static Uri buildUrlWithQueryParams(String url, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse(url);
    if (queryParams == null) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParams!,
      },
    );

  }
}