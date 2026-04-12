//
// WholesaleActiveView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct WholesaleActiveView: View {
    @ObservedObject var viewModel: WholesaleViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // MARK: Título
                Text("Mayoreo")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("ColorPrimary"))
                    .padding(.top, 56)
                    .padding(.leading, 20)
                    .padding(.bottom, 20)
                
                // MARK: Subtítulo
                Text("Tus promociones exclusivas")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color("ColorText").opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                
                // MARK: Promociones
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if viewModel.promotions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 40))
                            .foregroundColor(Color("ColorPrimary").opacity(0.25))
                        Text("No hay promociones activas\npor el momento.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("ColorText").opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.horizontal, 40)
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.promotions) { promotion in
                            promotionCard(promotion)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    private func promotionCard(_ promotion: Promotion) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("ColorSecondary").opacity(0.15))
                    .frame(width: 56, height: 56)
                VStack(spacing: 0) {
                    Text(promotion.formattedDiscount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color("ColorSecondary"))
                    Text("OFF")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color("ColorSecondary"))
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(promotion.description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("ColorText"))
                    .lineLimit(2)
                Text("Válida hasta: \(formattedDate(promotion.endDate))")
                    .font(.system(size: 12))
                    .foregroundColor(Color("ColorText").opacity(0.5))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("ColorPrimary").opacity(0.1), lineWidth: 1)
        )
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "es_SV")
        return formatter.string(from: date)
    }
}

// MARK: - Preview
struct WholesaleActiveView_Previews: PreviewProvider {
    static var previews: some View {
        WholesaleActiveView(
            viewModel: WholesaleViewModel(
                userId: "preview",
                userTier: .wholesale,
                inviteFriendUseCase: InviteFriendUseCase(
                    referralRepository: ReferralRepositoryImpl()
                )
            )
        )
    }
}
