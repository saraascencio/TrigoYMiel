//
//  PeriodFilterView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct PeriodFilterView: View {

    @Binding var selectedPeriod: ReportPeriodFilter
    let onSelect: ()  -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ReportPeriodFilter.allCases, id: \.self) { period in
                    FilterChip(
                        title:      period.rawValue,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                        onSelect()
                    }
                }
            }
            
        }
    }
}
