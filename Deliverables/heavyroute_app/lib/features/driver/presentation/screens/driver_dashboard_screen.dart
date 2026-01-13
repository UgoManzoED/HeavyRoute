import 'package:flutter/material.dart';
import '../../../../common/widgets/heavy_route_app_bar.dart';
import '../../../trips/models/trip_model.dart';
import '../../service/drive_trip_service.dart';
import '../widget/driver_trip_card.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> {
  final DriverTripService _driverService = DriverTripService();
  late Future<List<TripModel>> _tripsFuture;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() {
    setState(() {
      _tripsFuture = _driverService.getMyTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: HeavyRouteAppBar(
        subtitle: "Le tue Consegne",
        isLanding: false,
        onProfileTap: () {},
      ),
      body: FutureBuilder<List<TripModel>>(
        future: _tripsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Errore: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final trips = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _loadTrips(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              // +1 per il titolo "Prossime Destinazioni"
              itemCount: trips.length + 1,
              itemBuilder: (context, index) {
                // Intestazione
                if (index == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text("Prossime Destinazioni",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  );
                }

                final trip = trips[index - 1];

                // Qui usiamo il widget separato
                return DriverTripCard(
                  trip: trip,
                  onTripUpdated: _loadTrips, // Passiamo la funzione per ricaricare se cambia stato
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text("Nessuna consegna assegnata", style: TextStyle(fontSize: 18, color: Colors.grey)),
          TextButton(onPressed: _loadTrips, child: const Text("Aggiorna"))
        ],
      ),
    );
  }
}