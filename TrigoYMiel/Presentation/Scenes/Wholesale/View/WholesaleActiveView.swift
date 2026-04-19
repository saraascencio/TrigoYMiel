//
// WholesaleActiveView.swift
// TrigoYMiel
//
// Created by Sara Ascencio on 31/3/26.
//
import SwiftUI

struct WholesaleActiveView: View {

    @ObservedObject var viewModel: WholesaleViewModel
    let onCartTap: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Título
                HStack {
                    Text("Mayoreo")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color("ColorPrimary"))
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .padding(.bottom, 4)

                Text("Bienvenido al acceso mayorista")
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary").opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: Info card
                infoCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // MARK: Promociones
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color("ColorSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)

                } else if viewModel.promotions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tag.slash")
                            .font(.system(size: 40))
                            .foregroundColor(Color("ColorPrimary").opacity(0.2))
                        Text("No hay promociones activas")
                            .font(.subheadline)
                            .foregroundColor(Color("ColorPrimary").opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)

                } else {
                    Text("Promociones activas")
                        .font(.title3.bold())
                        .foregroundColor(Color("ColorPrimary"))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    
                    VStack(spacing: 12) {
                        ForEach(viewModel.promotions) { promotion in
                            PromotionCard(promotion: promotion)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Info card mayorista

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(Color("ColorSecondary"))
                Text("Acceso mayorista activo")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
            }

            Divider().overlay(Color("ColorPrimary").opacity(0.08))

            infoRow(icon: "cube.box.fill",     text: "Mínimo 75 unidades por pedido")
            infoRow(icon: "arrow.up.bin.fill",  text: "Máximo 1,000 unidades por pedido")
            infoRow(icon: "clock.badge.checkmark.fill",
                    text: "Requiere 3-4 días de anticipación")
            infoRow(icon: "tag.fill",           text: "Descuentos exclusivos en productos seleccionados")
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private func infoRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Color("ColorSecondary"))
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.7))
        }
    }
}

// MARK: - PromotionCard

struct PromotionCard: View {

    let promotion: Promotion

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(promotion.formattedDiscount)
                    .font(.title2.bold())
                    .foregroundColor(Color("ColorSecondary"))
                Text("de descuento")
                    .font(.subheadline)
                    .foregroundColor(Color("ColorPrimary").opacity(0.7))
                Spacer()
                Text("Mayoreo")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color("ColorPrimary"))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }

            Text(promotion.description)
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.6))

            HStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.caption2)
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                Text("Válido hasta \(formattedEnd)")
                    .font(.caption2)
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("ColorAccent").opacity(0.5), lineWidth: 1)
        )
        .shadow(color: Color("ColorPrimary").opacity(0.06), radius: 6, x: 0, y: 2)
    }

    private var formattedEnd: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale    = Locale(identifier: "es_SV")
        return f.string(from: promotion.endDate)
    }
}
