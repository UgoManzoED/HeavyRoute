import 'package:flutter/material.dart';
import 'features/requests/models/request_dto.dart';
import 'features/requests/services/request_service.dart';

void main() {
  runApp(const MaterialApp(home: TestPage()));
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Integrazione")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Dati finti per il test
            final dto = RequestCreationDTO(
              originAddress: "Napoli Porto",
              destinationAddress: "Roma Centro",
              pickupDate: "2026-05-20",
              weight: 1500.5,
              length: 10.0,
              width: 2.5,
              height: 3.0,
            );

            final success = await RequestService().createRequest(dto);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? "Inviato con successo!" : "Errore invio!"),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            }
          },
          child: const Text("INVIA RICHIESTA FINTA"),
        ),
      ),
    );
  }
}