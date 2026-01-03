import SwiftUI

struct MainView: View {
    @StateObject private var hub = IntelligenceHub()
    @State private var showingScanner = false
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    headerSection
                    
                    List {
                        // --- WEG 1: DER NEWS-TICKER ---
                        // Wenn man auf die News klickt, könnte man direkt eine Analyse starten
                        newsSection
                        
                        // --- WEG 2: DIE WISSENS-KARTEN (Wikipedia/DGE) ---
                        // Sobald eine Suche aktiv ist, zeigen wir diese Karten.
                        // Ein Klick darauf führt zur tiefen KI-Analyse.
                        if let eintrag = hub.activeLexikon {
                            Section("Klinisches Wissen") {
                                Button(action: { hub.showAIDetail = true }) {
                                    KnowledgeHubView(begriff: eintrag.name, fakten: eintrag.quellenFakten)
                                }
                                .buttonStyle(.plain) // Verhindert, dass die ganze Zelle blau wird
                            }
                        }
                        
                        // --- WEG 3: SEUBERT LAGERERGEBNISSE ---
                        if !searchText.isEmpty {
                            seubertSearchResultSection
                        }
                    }
                    .listStyle(.insetGrouped)
                    .searchable(text: $searchText, prompt: "Produkt oder Begriff...")
                    .onSubmit(of: .search) {
                        // AUTOMATIK: Beim Drücken von "Suchen" wird Pfad A sofort gestartet
                        Task { await hub.runLexikonSuche(begriff: searchText) }
                    }
                    
                    scanButton
                }
                .sheet(isPresented: $showingScanner) {
                    ScannerView(hub: hub)
                }
                
                // --- DIE WEITERLEITUNGEN (DESTINATIONS) ---

                // Ziel 1: Das KI-Labor (Pfad A)
                .navigationDestination(isPresented: $hub.showAIDetail) {
                    if let eintrag = hub.activeLexikon {
                        AIDetailView(productName: eintrag.name, analysis: eintrag.analysis)
                    }
                }
                
                // Ziel 2: Das Seubert-Lager (Pfad B)
                .navigationDestination(isPresented: $hub.showSeubertDetail) {
                    if let item = hub.activeSeubert {
                        SeubertDetailView(item: item)
                    }
                }
            }
        }
    }

    // MARK: - Sub-Views (Die Bausteine)

    private var headerSection: some View {
        VStack {
            Text("ChefIQ").font(.system(size: 34, weight: .black, design: .rounded))
            Text("Clinical & Culinary Assistant").font(.caption).foregroundColor(.secondary)
        }.padding(.top)
    }

    private var newsSection: some View {
        Section(header: Label("Gemini Update", systemImage: "sparkles")) {
            Text(hub.nutritionNews).font(.subheadline).italic()
        }
    }

    private var seubertSearchResultSection: some View {
        Section("Seubert Lager") {
            ForEach(hub.searchInCSV(query: searchText)) { item in
                Button(action: {
                    // Hier wählen wir das Lager-Item aus
                    hub.selectSeubertItem(item)
                }) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.name).bold()
                            Text("Art.Nr: \(item.articleNr)").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "shippingbox").foregroundColor(.blue)
                    }
                }
            }
        }
    }

    private var scanButton: some View {
        Button(action: { showingScanner = true }) {
            Label("Produkt scannen", systemImage: "barcode.viewfinder")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
        }.padding()
    }
}
