//
//  PromotionFormView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 8/5/26.
//
import SwiftUI


struct PromotionFormView: View {

    @StateObject var viewModel: PromotionFormViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("ColorBackground").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Header
                    HStack {
                        Button { dismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        Text(viewModel.isEditing ? "Editar promoción" : "Nueva promoción")
                            .font(.title3.bold())
                            .foregroundColor(Color("ColorPrimary"))
                            .padding(.leading, 8)
                        Spacer()
                    }
                    .padding(.top, 4)

                    descriptionField
                    discountField
                    datesSection
                    wholesaleToggle
                    productsSection

                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption.bold())
                                .foregroundColor(.red)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }

                    Button {
                        Task { await viewModel.savePromotion() }
                    } label: {
                        Group {
                            if viewModel.isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text(viewModel.isEditing ? "Guardar cambios" : "Crear promoción")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color("ColorSecondary"))
                    )
                    .disabled(viewModel.isSubmitting)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .task { await viewModel.loadProducts() }
        .alert(
            viewModel.isEditing ? "Promoción actualizada" : "Promoción creada",
            isPresented: $viewModel.savedSuccess
        ) {
            Button("OK", role: .cancel) { dismiss() }
        } message: {
            Text(viewModel.isEditing
                 ? "Los cambios se guardaron correctamente."
                 : "La promoción fue creada y ya está activa.")
        }
    }

    // MARK: - Descripción

    private var descriptionField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Descripción")
                .font(.subheadline.bold())
                .foregroundColor(Color("ColorPrimary"))

            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.description)
                    .frame(minHeight: 80)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.descriptionError != nil
                                ? Color.red.opacity(0.6)
                                : Color("ColorPrimary").opacity(0.20),
                                lineWidth: 1
                            )
                    )
                    .onChange(of: viewModel.description) { value in
                        let filtered = value.filter {
                            $0.isLetter || $0.isWhitespace || "%.,-".contains($0)
                        }
                        if filtered != value { viewModel.description = filtered }
                        if viewModel.description.count > viewModel.maxDescriptionLength {
                            viewModel.description = String(
                                viewModel.description.prefix(viewModel.maxDescriptionLength)
                            )
                        }
                        viewModel.validateDescription()
                    }
                    .overlay(alignment: .topLeading) {
                        if viewModel.description.isEmpty {
                            Text("Ej: 5% de descuento en alfajores...")
                                .font(.subheadline)
                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }

                Text("\(viewModel.descriptionCount)/\(viewModel.maxDescriptionLength)")
                    .font(.caption2)
                    .foregroundColor(
                        viewModel.descriptionCount >= viewModel.maxDescriptionLength
                        ? .red
                        : Color("ColorPrimary").opacity(0.4)
                    )
                    .padding(.trailing, 10)
                    .padding(.bottom, 8)
            }

            if let error = viewModel.descriptionError {
                Text(error).font(.caption).foregroundColor(.red)
            }
        }
    }

    // MARK: - Descuento

    private var discountField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Porcentaje de descuento (%)")
                .font(.subheadline.bold())
                .foregroundColor(Color("ColorPrimary"))

            HStack(spacing: 12) {
                TextField("Ej. 10", text: $viewModel.discountPercentage)
                    .keyboardType(.numberPad)
                    .onChange(of: viewModel.discountPercentage) { _ in
                        viewModel.validateDiscount()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                viewModel.discountError != nil
                                ? Color.red.opacity(0.6)
                                : Color("ColorPrimary").opacity(0.20),
                                lineWidth: 1
                            )
                    )

                Text(
                    viewModel.discountPercentage.isEmpty
                    ? "—"
                    : "\(viewModel.discountPercentage)%"
                )
                .font(.title3.bold())
                .foregroundColor(Color("ColorSecondary"))
                .frame(width: 60)
            }

            Text("Máximo \(viewModel.maxDiscount)%, solo números enteros.")
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.45))

            if let error = viewModel.discountError {
                Text(error).font(.caption).foregroundColor(.red)
            }
        }
    }

    // MARK: - Fechas

    private var datesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vigencia de la promoción")
                .font(.subheadline.bold())
                .foregroundColor(Color("ColorPrimary"))

            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fecha inicio")
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.55))
                        Text("La promoción comienza este día")
                            .font(.caption2)
                            .foregroundColor(Color("ColorPrimary").opacity(0.35))
                    }
                    Spacer()
                    DatePicker(
                        "",
                        selection:           $viewModel.startDate,
                        in:                  Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .tint(Color("ColorSecondary"))
                    .onChange(of: viewModel.startDate) { _ in
                        if viewModel.endDate <= viewModel.startDate {
                            viewModel.endDate = Calendar.current.date(
                                byAdding: .day, value: 1, to: viewModel.startDate
                            ) ?? viewModel.startDate
                        }
                        viewModel.validateDates()
                    }
                }
                .padding(14)

                Divider().padding(.horizontal, 14)

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Fecha fin")
                            .font(.caption)
                            .foregroundColor(Color("ColorPrimary").opacity(0.55))
                        Text("La promoción termina este día")
                            .font(.caption2)
                            .foregroundColor(Color("ColorPrimary").opacity(0.35))
                    }
                    Spacer()
                    DatePicker(
                        "",
                        selection:           $viewModel.endDate,
                        in:                  viewModel.dateRangeForEnd,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .tint(Color("ColorSecondary"))
                    .onChange(of: viewModel.endDate) { _ in
                        viewModel.validateDates()
                    }
                }
                .padding(14)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.dateError != nil
                        ? Color.red.opacity(0.6)
                        : Color("ColorPrimary").opacity(0.12),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color("ColorPrimary").opacity(0.05), radius: 4, x: 0, y: 2)

            if let error = viewModel.dateError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption).foregroundColor(.red)
                    Text(error).font(.caption).foregroundColor(.red)
                }
            }
        }
    }

    // MARK: - Solo mayoreo

    private var wholesaleToggle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Solo para mayoristas")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
                Text("Si está activo, aplica únicamente a clientes mayoristas.")
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.5))
            }
            Spacer()
            Toggle("", isOn: $viewModel.wholesaleOnly)
                .labelsHidden()
                .tint(Color("ColorSecondary"))
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color("ColorPrimary").opacity(0.05), radius: 4, x: 0, y: 2)
    }

    // MARK: - Productos

    private var productsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Productos aplicables")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("ColorPrimary"))
                Spacer()
                if !viewModel.selectedProductIds.isEmpty {
                    Text("\(viewModel.selectedProductIds.count) seleccionados")
                        .font(.caption.bold())
                        .foregroundColor(Color("ColorSecondary"))
                }
            }

            Text("Selecciona los productos a los que aplica el descuento.")
                .font(.caption)
                .foregroundColor(Color("ColorPrimary").opacity(0.5))

            if viewModel.isLoadingProducts {
                ProgressView()
                    .tint(Color("ColorSecondary"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else if viewModel.availableProducts.isEmpty {
                Text("No hay productos disponibles.")
                    .font(.caption)
                    .foregroundColor(Color("ColorPrimary").opacity(0.4))
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.availableProducts) { product in
                        productRow(product)
                        if product.id != viewModel.availableProducts.last?.id {
                            Divider().padding(.horizontal, 14)
                        }
                    }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.productsError != nil
                            ? Color.red.opacity(0.6)
                            : Color("ColorPrimary").opacity(0.12),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color("ColorPrimary").opacity(0.05), radius: 4, x: 0, y: 2)
            }

            if let error = viewModel.productsError {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.caption).foregroundColor(.red)
                    Text(error).font(.caption).foregroundColor(.red)
                }
            }
        }
    }

    private func productRow(_ product: Product) -> some View {
        let isSelected = viewModel.isSelected(product.id)
        return Button {
            viewModel.toggleProduct(product.id)
        } label: {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: product.imageURL)) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    case .failure:          Color("ColorAccent").opacity(0.3)
                    default:                Color("ColorAccent").opacity(0.2)
                    }
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(product.name)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("ColorPrimary"))
                    Text(product.formattedPrice)
                        .font(.caption)
                        .foregroundColor(Color("ColorPrimary").opacity(0.55))
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(
                        isSelected ? Color("ColorSecondary") : Color("ColorPrimary").opacity(0.25)
                    )
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }
}
