import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../model/vehicle_dto.dart';

/**
 * Service responsabile della gestione tecnica e operativa della flotta veicoli.
 * <p>
 * Interagisce con gli endpoint del planner per monitorare lo stato dei mezzi,
 * le loro capacità di carico e le dimensioni fisiche.
 * </p>
 * @author Roman
 */
class VehicleService {
  /** Istanza del client HTTP con supporto JWT. */
  final Dio _dio = DioClient.instance;

  /**
   * Recupera la lista completa dei veicoli censiti nel sistema.
   * <p>
   * Utilizzato dal Planner per visualizzare la flotta e verificare le disponibilità.
   * </p>
   * @return Una lista di {@link VehicleDTO}.
   */
  Future<List<VehicleDTO>> getVehicles() async {
    try {
      final response = await _dio.get('/planner/vehicles');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        return data.map((json) => VehicleDTO.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      _logError("getVehicles", e);
      return [];
    }
  }

  /**
   * Registra un nuovo veicolo nella flotta aziendale.
   * @param vehicle I dati tecnici del nuovo mezzo.
   * @return true se il veicolo è stato creato con successo.
   */
  Future<bool> createVehicle(VehicleDTO vehicle) async {
    try {
      final response = await _dio.post('/planner/vehicles', data: vehicle.toJson());
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      _logError("createVehicle", e);
      return false;
    }
  }

  /**
   * Helper privato per il logging degli errori di rete.
   */
  void _logError(String method, DioException e) {
    print("--- ERRORE VEHICLE_SERVICE ($method) ---");
    print("Status: ${e.response?.statusCode}");
    print("Dettagli: ${e.response?.data}");
  }
}