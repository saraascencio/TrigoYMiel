//
//  SalesChartView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct SalesChartView: View {

    let activities: [DayActivity]
    @Binding var chartMode: ChartMode

    private var maxValue: Double {
        switch chartMode {
        case .units:
            return Double(activities.map { $0.units }.max() ?? 1)
        case .revenue:
            return activities.map { $0.revenue }.max() ?? 1
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // MARK: Header con toggle
            HStack {
                Text("Actividad por día")
                    .font(.headline.bold())
                    .foregroundColor(Color("ColorPrimary"))

                Spacer()

                // Toggle Unidades / Ingresos
                HStack(spacing: 0) {
                    ForEach(ChartMode.allCases, id: \.self) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                chartMode = mode
                            }
                        } label: {
                            Text(mode.rawValue)
                                .font(.caption.bold())
                                .foregroundColor(
                                    chartMode == mode ? .white : Color("ColorPrimary")
                                )
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    chartMode == mode
                                    ? Color("ColorSecondary")
                                    : Color.clear
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }
                }
                .background(Color("ColorPrimary").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            // MARK: Barras horizontales
            VStack(spacing: 14) {
                ForEach(activities) { activity in
                    HStack(spacing: 12) {

                        // Día
                        Text(activity.day)
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.7))
                            .frame(width: 72, alignment: .leading)

                        // Barra
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("ColorPrimary").opacity(0.08))
                                    .frame(height: 8)

                                let ratio = maxValue > 0
                                    ? currentValue(activity) / maxValue
                                    : 0

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color("ColorSecondary"))
                                    .frame(
                                        width: geo.size.width * ratio,
                                        height: 8
                                    )
                                    .animation(.easeInOut(duration: 0.3), value: chartMode)
                            }
                        }
                        .frame(height: 8)

                        // Valor
                        Text(formattedValue(activity))
                            .font(.caption.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .frame(width: 40, alignment: .trailing)
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 3)        
    }

    private func currentValue(_ activity: DayActivity) -> Double {
        switch chartMode {
        case .units:   return Double(activity.units)
        case .revenue: return activity.revenue
        }
    }

    private func formattedValue(_ activity: DayActivity) -> String {
        switch chartMode {
        case .units:   return "\(activity.units)"
        case .revenue:
            return String(format: "$%.2f", activity.revenue)
        }
    }
}
