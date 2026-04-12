//
//  ReportsView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct ReportsView: View {
    
    @StateObject var viewModel: ReportsViewModel
    @State private var pdfData: Data?
    @State private var showShare = false
    let onLogout:  () -> Void
    let onSupport: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorBackground").ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    content
                }
            }
        }
        .onAppear {
            if viewModel.report == nil {
                Task { await viewModel.loadReport() }
            }
        }
        .sheet(isPresented: $showShare) {
            if let data = pdfData {
                ShareSheet(data: data, fileName: viewModel.reportFileName)
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                header
                
       
                PeriodFilterView(
                    selectedPeriod: $viewModel.selectedPeriod
                ) {
                    Task {
                        await viewModel.loadReport()
                    }
                }
                .padding(.horizontal, 5)
                .padding(.top, 8)
                
                metrics
                
                SalesChartView(
                    activities: viewModel.activities,
                    chartMode: $viewModel.chartMode
                )
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
    
    private var header: some View {
        HStack {
            Text("Reportes")
                .font(.title.bold())
                .foregroundColor(Color("ColorPrimary"))

            Spacer()

            Button {
                Task {
                    pdfData  = await viewModel.exportPDF()
                    showShare = pdfData != nil
                }
            } label: {
                if viewModel.isExporting {
                    ProgressView()
                } else {
                    Text("Exportar")
                }
            }

            ProfileMenuButton(       
                onLogout:  { onLogout() },
                onSupport: { onSupport() }
            )
        }
    }
    private var metrics: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 12
        ) {
            
            KPIBox(
                title: "Total ventas",
                value: "\(viewModel.totalUnitsSold)",
                subtitle: "Unidades"
            )
            
            KPIBox(
                title: "Ingresos",
                value: String(format: "$%.2f", viewModel.totalRevenue),
                subtitle: "Total"
            )
            
            KPIBox(
                title: "Promedio diario",
                value: String(format: "$%.2f", viewModel.averageDailyRevenue),
                subtitle: "Por día"
            )
            
            KPIBox(
                title: "Mejor día",
                value: viewModel.bestDay?.day ?? "--",
                subtitle: viewModel.bestDay != nil
                ? "\(viewModel.bestDay!.units) uds"
                : "Sin datos"
            )
        }
    }
    
    
}
// MARK: - ShareSheet

struct ShareSheet: UIViewControllerRepresentable {

    let data: Data
    let fileName: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)

        try? data.write(to: url)

        return UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct KPIBox: View {

    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)

            Text(value)
                .font(.title2.bold())

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
