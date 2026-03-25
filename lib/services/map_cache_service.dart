import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';

/// A service to handle map tile caching and proactive pre-fetching (seeding).
class MapCacheService {
  static late final FileCacheStore cacheStore;
  static bool _initialized = false;
  static final Dio _dio = Dio();

  static Future<void> init() async {
    if (_initialized) return;
    final cacheDir = await getApplicationSupportDirectory();

    // http_cache_file_store provides the FileCacheStore for dio_cache_interceptor v4+
    cacheStore = FileCacheStore('${cacheDir.path}/map_tiles');

    // Add interceptor for seeding using v4.0+ syntax
    _dio.interceptors.add(DioCacheInterceptor(
        options: CacheOptions(
      store: cacheStore,
      policy: CachePolicy.forceCache,
      hitCacheOnNetworkFailure: true,
      maxStale: const Duration(days: 7),
    )));

    _initialized = true;
  }

  /// Proactively seeds (downloads) tiles in a 1km radius around a center point.
  static Future<void> seedArea(LatLng center,
      {int minZoom = 15, int maxZoom = 17}) async {
    if (!_initialized) await init();

    const double radiusDegrees = 0.01;
    final List<String> urls = [];

    for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
      final northTile = _latLngToTile(
          LatLng(center.latitude + radiusDegrees, center.longitude), zoom);
      final southTile = _latLngToTile(
          LatLng(center.latitude - radiusDegrees, center.longitude), zoom);
      final eastTile = _latLngToTile(
          LatLng(center.latitude, center.longitude + radiusDegrees), zoom);
      final westTile = _latLngToTile(
          LatLng(center.latitude, center.longitude - radiusDegrees), zoom);

      for (int x = westTile.x; x <= eastTile.x; x++) {
        for (int y = northTile.y; y <= southTile.y; y++) {
          final url = 'https://mt1.google.com/vt/lyrs=m&x=$x&y=$y&z=$zoom';
          urls.add(url);
        }
      }
    }

    // Limit concurrency to avoid overwhelming network
    const int concurrency = 5;
    for (int i = 0; i < urls.length; i += concurrency) {
      final end = (i + concurrency < urls.length) ? i + concurrency : urls.length;
      final batch = urls.sublist(i, end);
      await Future.wait(batch.map((url) => _prefetchTile(url)));
    }
  }

  static Future<void> _prefetchTile(String url) async {
    try {
      await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
    } catch (_) {
      // Ignore failures during prefetch
    }
  }

  static _TileCoords _latLngToTile(LatLng loc, int zoom) {
    final n = math.pow(2.0, zoom);
    final x = ((loc.longitude + 180.0) / 360.0 * n).floor();
    final y = ((1.0 -
                math.log(math.tan(loc.latitude * math.pi / 180.0) +
                        1.0 / math.cos(loc.latitude * math.pi / 180.0)) /
                    math.pi) /
            2.0 *
            n)
        .floor();
    return _TileCoords(x, y);
  }
}

class _TileCoords {
  final int x;
  final int y;
  _TileCoords(this.x, this.y);
}
