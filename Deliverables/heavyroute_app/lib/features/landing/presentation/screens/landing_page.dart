import 'package:flutter/material.dart';
// Verifica che questo percorso sia corretto nel tuo progetto
import '../../../../common/widgets/heavy_route_app_bar.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Blocchiamo il tasto indietro e lo swipe (freccia fantasma)
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const HeavyRouteAppBar(
          subtitle: "Soluzioni per la Logistica",
          isLanding: true,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 800;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeroSection(context, isMobile),
                  _buildFeaturesSection(context, isMobile),
                  _buildInfoSection(context, isMobile),
                  _buildFooter(context, isMobile),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 2. HERO SECTION (Titolo + Camion) ---
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: isMobile ? 100 : 150,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 20),
          Text(
            "HEAVY\nROUTE",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 40 : 64,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).primaryColor,
              height: 0.9,
            ),
          ),
          const SizedBox(height: 30),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const Text(
              "Specializzati in consegne pesanti e di grandi dimensioni.\nAffidabilità e professionalità per le tue spedizioni speciali.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.blueGrey, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 22),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 5,
            ),
            child: const Text("Richiedi Consegna Speciale"),
          ),
        ],
      ),
    );
  }

  // --- 3. FEATURES ---
  Widget _buildFeaturesSection(BuildContext context, bool isMobile) {
    final cards = [
      _buildFeatureCard(context, Icons.inventory_2_outlined, "Carichi Pesanti", "Gestiamo spedizioni di qualsiasi peso e dimensione con attrezzature specializzate."),
      _buildFeatureCard(context, Icons.map_outlined, "Tracciamento Live", "Monitora in tempo reale la tua spedizione dall'inizio alla destinazione finale."),
      _buildFeatureCard(context, Icons.schedule, "Consegna Puntuale", "Garanzia di consegna nei tempi stabiliti con servizio dedicato e prioritario."),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
      child: isMobile
          ? Column(children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 24), child: c)).toList())
          : Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: c))).toList(),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF0F9FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor, size: 32),
          ),
          const SizedBox(height: 24),
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 12),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey, height: 1.5)),
        ],
      ),
    );
  }

  // --- 4. INFO SECTION ---
  Widget _buildInfoSection(BuildContext context, bool isMobile) {
    Widget textContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            "La Tua Soluzione per Consegne Speciali",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)
        ),
        const SizedBox(height: 24),
        const Text(
          "HeavyRoute è leader nel settore delle consegne pesanti. Con oltre 15 anni di esperienza, offriamo un servizio completo e personalizzato per ogni esigenza di trasporto eccezionale.",
          style: TextStyle(fontSize: 16, color: Colors.blueGrey, height: 1.6),
        ),
        const SizedBox(height: 32),
        _buildCheckItem("Attrezzature specializzate per carichi pesanti"),
        _buildCheckItem("Personale qualificato e certificato"),
        _buildCheckItem("Copertura assicurativa completa"),
        _buildCheckItem("Assistenza clienti 24/7"),
      ],
    );

    Widget visualContent = Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 64, color: Colors.grey),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: isMobile
          ? Column(children: [textContent, const SizedBox(height: 40), visualContent])
          : Row(
        children: [
          Expanded(flex: 5, child: textContent),
          const SizedBox(width: 60),
          Expanded(flex: 4, child: visualContent),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: Color(0xFF10B981)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF374151), fontSize: 16))),
        ],
      ),
    );
  }

  // --- 5. FOOTER ---
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.spaceBetween,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.white, size: 28),
                        SizedBox(width: 10),
                        Text("HeavyRoute", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                        "Il tuo partner affidabile per consegne pesanti e spedizioni speciali in tutta Italia.",
                        style: TextStyle(color: Color(0xFF94A3B8), height: 1.5)
                    ),
                  ],
                ),
              ),
              _buildFooterColumn("Contatti", [
                "+39 02 1234 5678",
                "info@heavyroute.it",
                "Via Logistica 123, Milano"
              ], icons: [Icons.phone, Icons.email, Icons.location_on]),
              _buildFooterColumn("Orari di Servizio", [
                "Lun - Ven: 8:00 - 19:00",
                "Sabato: 8:00 - 13:00",
                "Domenica: Chiuso"
              ], icons: [Icons.access_time, null, null]),
            ],
          ),
          const SizedBox(height: 60),
          const Divider(color: Color(0xFF1E293B)),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("© 2025 HeavyRoute. Tutti i diritti riservati.", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              Text("Privacy Policy   Termini", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFooterColumn(String title, List<String> items, {List<IconData?>? icons}) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ...List.generate(items.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (icons != null && index < icons.length && icons[index] != null)
                    Padding(padding: const EdgeInsets.only(right: 10), child: Icon(icons[index], color: const Color(0xFF94A3B8), size: 16)),
                  Expanded(child: Text(items[index], style: const TextStyle(color: Color(0xFF94A3B8), height: 1.4))),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}