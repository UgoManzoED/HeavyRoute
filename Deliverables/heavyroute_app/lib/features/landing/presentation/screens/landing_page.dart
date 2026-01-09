import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder ci permette di rendere la pagina responsive (Mobile vs Desktop)
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildHeroSection(context, isMobile),
                _buildFeaturesSection(context, isMobile),
                _buildInfoSection(context, isMobile),
                _buildFooter(context, isMobile),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- 1. HEADER (Logo + Tasto Login) ---
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo Brand
          Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Theme.of(context).colorScheme.secondary, size: 32),
              const SizedBox(width: 8),
              Text(
                "HEAVY\nROUTE",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).primaryColor,
                  height: 0.9,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          // Login Button
          OutlinedButton(
            onPressed: () {
              // Naviga alla schermata di Login che abbiamo creato
              Navigator.pushNamed(context, '/login');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              "Area Riservata",
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. HERO SECTION (Titolo + Camion) ---
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFFF8FAFC), // Sfondo grigio chiarissimo
      child: Column(
        children: [
          // Icona Grande (al posto dell'immagine del camion giallo)
          Icon(
            Icons.local_shipping_outlined,
            size: isMobile ? 100 : 150,
            color: Theme.of(context).primaryColor
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
          // Slogan
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: const Text(
              "Specializzati in consegne pesanti e di grandi dimensioni.\nAffidabilità e professionalità per le tue spedizioni speciali.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.blueGrey, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          // CTA Button
          ElevatedButton(
            onPressed: () {
               // Porta al login per fare una richiesta
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

  // --- 3. FEATURES (Le 3 card) ---
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
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
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

  // --- 4. INFO SECTION (Testo + Immagine) ---
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

    // Placeholder visivo per la parte destra (slider/frecce)
    Widget visualContent = Container(
      height: 300,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Center(
        child: Icon(Icons.image_outlined, size: 64, color: Colors.grey[300]),
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
          const Icon(Icons.check_circle, size: 20, color: Color(0xFF10B981)), // Verde smeraldo
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF374151), fontSize: 16))),
        ],
      ),
    );
  }

  // --- 5. FOOTER (Scuro) ---
  Widget _buildFooter(BuildContext context, bool isMobile) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Navy Background (coerente con le foto)
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Column(
        children: [
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Logo e Descrizione
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
              // Contatti
              _buildFooterColumn("Contatti", [
                "+39 02 1234 5678",
                "info@heavyroute.it",
                "Via Logistica 123, Milano"
              ], icons: [Icons.phone, Icons.email, Icons.location_on]),
               // Orari
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
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