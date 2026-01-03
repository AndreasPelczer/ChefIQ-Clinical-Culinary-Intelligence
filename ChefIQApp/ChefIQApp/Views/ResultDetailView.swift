import SwiftUI

struct ResultDetailView: View {
    @ObservedObject var hub: IntelligenceHub
    var storedEntry: StoredAnalysis? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // TITEL: Entweder aus CoreData oder aus dem aktuellen Lexikon-Eintrag
                Text(storedEntry?.productName ?? hub.activeLexikon?.name ?? "Analyse")
                    .font(.largeTitle).bold()
                
                if let analysis = hub.activeLexikon?.analysis {
                    InfoBlock(title: "Broteinheiten", value: analysis.beValue, icon: "chart.bar", color: .blue)
                    InfoBlock(title: "Hinweis", value: analysis.medicalNote, icon: "info.circle", color: .red)
                } else if let entry = storedEntry {
                    InfoBlock(title: "Broteinheiten", value: entry.beValue ?? "n/a", icon: "chart.bar", color: .blue)
                }
            }.padding()
        }
    }
}
