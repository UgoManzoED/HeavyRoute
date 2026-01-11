import 'package:json_annotation/json_annotation.dart';
import '../../../common/models/enums.dart';
import '../../auth/models/user_model.dart';
import 'load_details.dart';

part 'transport_request.g.dart';

@JsonSerializable()
class TransportRequest {
  final int id;

  // Date di audit
  final DateTime createdAt;

  // L'oggetto cliente
  final UserModel client;

  final String originAddress;
  final String destinationAddress;

  // Data del ritiro
  final DateTime pickupDate;

  // Stato della richiesta
  final RequestStatus requestStatus;

  // Dettagli carico embedded
  final LoadDetails load;

  TransportRequest({
    required this.id,
    required this.createdAt,
    required this.client,
    required this.originAddress,
    required this.destinationAddress,
    required this.pickupDate,
    required this.requestStatus,
    required this.load,
  });

  String get customerName {
    if (client.companyName != null && client.companyName!.isNotEmpty) {
      return client.companyName!;
    }
    return "${client.firstName} ${client.lastName}";
  }

  factory TransportRequest.fromJson(Map<String, dynamic> json) => _$TransportRequestFromJson(json);
  Map<String, dynamic> toJson() => _$TransportRequestToJson(this);
}