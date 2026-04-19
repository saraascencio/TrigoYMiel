//
//  PickupTimeSelectorView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct PickupTimeSelectorView: View {
    @Binding var pickupDate: Date
    let isWholesaleValid: Bool
    let totalUnits: Int 
    let minDate: Date
    
 
    private var isWholesaleFlow: Bool {
        return isWholesaleValid && totalUnits >= 75
    }
    
    private var elSalvadorCalendar: Calendar {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: "America/El_Salvador") {
            calendar.timeZone = tz
        }
        return calendar
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(isWholesaleFlow ? "Selecciona fecha de retiro" : "Recoger hoy")
                        .font(.caption.bold())
                        .foregroundColor(Color("ColorSecondary"))
                    
                    Text(isWholesaleFlow
                         ? "Mínimo 3 días de anticipación"
                         : "Horario SV: 10:00 am - 8:00 pm")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isWholesaleFlow {
               
                    DatePicker(
                        "",
                        selection: $pickupDate,
                        in: minDate...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .environment(\.calendar, elSalvadorCalendar)
                    .environment(\.timeZone, elSalvadorCalendar.timeZone)
                    .tint(Color("ColorSecondary"))
                    
                } else {
                  
                    if Date() > calendarEnd {
                        Text("Cerrado")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                    } else {
                        DatePicker(
                            "",
                            selection: $pickupDate,
                            in: Date()...,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .environment(\.calendar, elSalvadorCalendar)
                        .environment(\.timeZone, elSalvadorCalendar.timeZone)
                        .tint(Color("ColorSecondary"))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("ColorSecondary").opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("ColorSecondary").opacity(0.3), lineWidth: 1)
        )
    }
    
    private var calendarEnd: Date {
        let calendar = elSalvadorCalendar
        var comps = calendar.dateComponents([.year, .month, .day], from: Date())
        comps.hour = 20
        comps.minute = 0
        return calendar.date(from: comps) ?? Date()
    }
}
