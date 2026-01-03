import Foundation
import SwiftUI
import UIKit

@MainActor
class IntelligenceHub: ObservableObject {
    // MARK: - Parkplätze
    @Published var activeLexikon: LexikonEintrag?
    @Published var activeSeubert: SeubertItem?
    
    @Published var isLoading: Bool = false
    @Published var nutritionNews: String = "Lade klinische Fakten..."
    
    // NAVIGATION
    @Published var showAIDetail: Bool = false
    @Published var showSeubertDetail: Bool = false

    private let aiService = GeminiClinicalService()
    private let csvService = CSVDataService()
    private let ocrService = OCRService()

    init() { fetchDailyNutritionNews() }

    // MARK: - PFAD A: KI-LEXIKON (Die Suche mit Quellen)
    func runLexikonSuche(begriff: String) async {
        self.isLoading = true
        // 1. Neuen, leeren Eintrag erstellen
        self.activeLexikon = LexikonEintrag(name: begriff)
        self.showAIDetail = true
        
        fetchDailyNutritionNews(for: begriff)
        
        // 2. Parallel-Aktion: Nährwerte UND Quellen-Fakten laden
        await fetchFullAnalysis(for: begriff)
        
        self.isLoading = false
    }

    // MARK: - PFAD B: SEUBERT LAGER
    func selectSeubertItem(_ item: SeubertItem) {
        self.activeSeubert = item
        self.showSeubertDetail = true
        fetchDailyNutritionNews(for: item.name)
        
        Task {
            await fetchFullAnalysis(for: item.name)
        }
    }

    private func fetchFullAnalysis(for name: String) async {
            do {
                // 1. Die Analyse von Gemini anfordern (inkl. der neuen 'sources')
                let result = try await aiService.fetchAnalysis(for: name)
                
                // 2. Umwandlung: Von JSON-Quellen zu UI-Quellen
                // Wir nutzen die Daten aus dem result.sources Array
                var neueQuellen: [QuellenInfo] = []
                
                if let aiSources = result.sources {
                    neueQuellen = aiSources.map { item in
                        QuellenInfo(quelle: item.q, aussage: item.a)
                    }
                } else {
                    // Sicherheitsnetz, falls Gemini mal keine Quellen schickt
                    neueQuellen = [
                        QuellenInfo(quelle: "Info", aussage: "Keine spezifischen Quellen-Fakten verfügbar.")
                    ]
                }
                
                // 3. Update des aktiven Lexikons auf dem MainActor
                if var current = self.activeLexikon {
                    current.analysis = result
                    current.quellenFakten = neueQuellen // Hier fließen die Wikipedia/DGE Infos ein
                    self.activeLexikon = current
                    
                    // Wir stoßen das UI-Update manuell an
                    self.objectWillChange.send()
                    print("✅ Wissen erfolgreich aggregiert für: \(name)")
                }
            } catch {
                print("❌ Fehler im Wissens-Hub: \(error.localizedDescription)")
            }
        }
    // MARK: - NEWS & SCANNER
    func processImage(_ image: UIImage) async {
        self.isLoading = true
        ocrService.performOCR(on: image) { [weak self] observations in
            let detectedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")
            Task { @MainActor in
                if !detectedText.isEmpty { await self?.runLexikonSuche(begriff: detectedText) }
                else { self?.isLoading = false }
            }
        }
    }

    func fetchDailyNutritionNews(for query: String? = nil) {
        Task {
            let topic = query ?? "Ernährungswissenschaft"
            let response = (try? await aiService.fetchRawText(prompt: "Nenne einen spannenden klinischen Fakt über \(topic) mit Quellenbezug (max 2 Sätze).")) ?? "Keine News verfügbar."
            self.nutritionNews = response
        }
    }

    func searchInCSV(query: String) -> [SeubertItem] {
        return csvService.filterInventory(query: query)
    }
}
