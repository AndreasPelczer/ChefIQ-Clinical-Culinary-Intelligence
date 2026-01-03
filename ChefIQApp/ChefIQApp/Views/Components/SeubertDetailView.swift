import SwiftUI

/// FENSTER 3: Reine Lager-Detailansicht (Pfad B)
/// Zeigt ausschließlich Daten aus der lokalen 'Produkte.csv'
struct SeubertDetailView: View {
    // Nur das Seubert-Item, keine ClinicalAnalysis mehr!
    let item: SeubertItem
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // TITEL & ARTIKELNUMMER (Direkt aus CSV)
                VStack(alignment: .leading, spacing: 5) {
                    Text(item.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    Text("ARTIKELNUMMER: \(item.articleNr)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // SEKTION 1: LAGER-LOGISTIK
                SectionView(title: "Bestandsdaten & Kategorie",
                            icon: "shippingbox.fill",
                            color: .blue) {
                    VStack(alignment: .leading, spacing: 10) {
                        DetailRow(label: "Kategorie", value: item.category)
                        DetailRow(label: "Lieferant", value: item.supplier)
                    }
                }
                
                // SEKTION 2: OFFIZIELLE ALLERGENE (Das Herzstück der CSV)
                SectionView(title: "Gesetzliche Allergene",
                            icon: "exclamationmark.triangle.fill",
                            color: .red) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Die schicken Badges für die schnelle Erkennung
                        AllergenBadgeView(allergenCodes: item.allergenCodes)
                        
                        if !item.additiveCodes.isEmpty {
                            Divider()
                            Text("Zusatzstoffe (Codes): \(item.additiveCodes)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // SEKTION 3: KÜCHEN-ANWEISUNG
                if !item.cookingInstruction.isEmpty {
                    SectionView(title: "Zubereitungshinweis",
                                icon: "cooktop.fill",
                                color: .orange) {
                        Text(item.cookingInstruction)
                            .font(.body)
                            .italic()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Lagerartikel")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Kleine Hilfs-View für die Tabelle
struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label).foregroundColor(.secondary)
            Spacer()
            Text(value).bold()
        }
        .font(.subheadline)
    }
}
