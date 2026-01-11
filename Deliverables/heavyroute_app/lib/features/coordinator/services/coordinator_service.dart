import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../dto/proposed_route_dto.dart';

class TrafficCoordinatorService {
  final Dio _dio = DioClient.instance;

  // Endpoint: GET /api/traffic-coordinator/routes
  Future<List<ProposedRouteDTO>> getProposedRoutes() async {
    try {
      final response = await _dio.get('/traffic-coordinator/routes');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> list = response.data;
        return list.map((json) => ProposedRouteDTO.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Errore getProposedRoutes: $e");
      return [];
    }
  }

  // Endpoint: PATCH /api/traffic-coordinator/routes/{id}/validate
  Future<bool> validateRoute(String routeId, bool isApproved) async {
    try {
      final response = await _dio.patch(
        '/traffic-coordinator/routes/$routeId/validate',
        queryParameters: {'approved': isApproved},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Errore validateRoute: $e");
      return false;
    }
  }
}