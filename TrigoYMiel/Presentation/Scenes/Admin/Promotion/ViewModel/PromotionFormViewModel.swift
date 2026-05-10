//
//  PromotionFormViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 8/5/26.
//
import Foundation
import Combine

enum PromotionFormMode {
    case create
    case edit(Promotion)
}

@MainActor
final class PromotionFormViewModel: ObservableObject {

    // MARK: - Modo
    let mode: PromotionFormMode

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    // MARK: - Campos
    @Published var description:        String      = ""
    @Published var discountPercentage: String      = ""
    @Published var startDate:          Date        = Date()
    @Published var endDate:            Date        = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var wholesaleOnly:      Bool        = false
    @Published var selectedProductIds: Set<String> = []

    // MARK: - Errores
    @Published var descriptionError: String? = nil
    @Published var discountError:    String? = nil
    @Published var dateError:        String? = nil
    @Published var productsError:    String? = nil

    // MARK: - State
    @Published var isSubmitting:      Bool    = false
    @Published var errorMessage:      String? = nil
    @Published var savedSuccess:      Bool    = false
    @Published var availableProducts: [Product] = []
    @Published var isLoadingProducts: Bool    = false

    // MARK: - Constantes
    let maxDescriptionLength = 150
    let maxDiscount          = 90

    // MARK: - Dependencias
    private let promotionDataSource: PromotionFirestoreDataSource
       private let productRepository: ProductRepository
       private let onSave: (Promotion) -> Void

       init(
           mode: PromotionFormMode,
           promotionDataSource: PromotionFirestoreDataSource? = nil,
           productRepository: ProductRepository? = nil,
           onSave: @escaping (Promotion) -> Void
       ) {
           self.mode = mode
           self.promotionDataSource = promotionDataSource ?? PromotionFirestoreDataSource()
           self.productRepository = productRepository ?? ProductRepositoryImpl()
           self.onSave = onSave

           prefill()
       }
    // MARK: - Prefill en modo edición

    private func prefill() {
        guard case .edit(let promo) = mode else { return }
        description        = promo.description
        discountPercentage = "\(Int(promo.discountPercentage))"
        startDate          = promo.startDate
        endDate            = promo.endDate
        wholesaleOnly      = promo.wholesaleOnly
        selectedProductIds = Set(promo.applicableProductIds)
    }

    // MARK: - Computed

    var descriptionCount: Int { description.count }
    var discountValue:    Int  { Int(discountPercentage) ?? 0 }

    var dateRangeForEnd: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .day, value: 1, to: startDate) ?? startDate
        let max = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? startDate
        return min...max
    }

    // MARK: - Cargar productos

    func loadProducts() async {
        isLoadingProducts = true
        do {
            availableProducts = try await productRepository.getAllProducts()
        } catch {
            errorMessage = "No se pudieron cargar los productos."
        }
        isLoadingProducts = false
    }

    func toggleProduct(_ productId: String) {
        if selectedProductIds.contains(productId) {
            selectedProductIds.remove(productId)
        } else {
            selectedProductIds.insert(productId)
        }
        validateProducts()
    }

    func isSelected(_ productId: String) -> Bool {
        selectedProductIds.contains(productId)
    }

    // MARK: - Validaciones

    func validateDescription() {
        let trimmed = description.trimmingCharacters(in: .whitespaces)
        descriptionError = trimmed.isEmpty        ? "La descripción es obligatoria."           :
                           trimmed.count > maxDescriptionLength ? "Máximo \(maxDescriptionLength) caracteres." : nil
    }

    func validateDiscount() {
        let filtered = discountPercentage.filter { $0.isNumber }
        if filtered != discountPercentage { discountPercentage = filtered }
        if filtered.isEmpty {
            discountError = "El descuento es obligatorio."
        } else if let v = Int(filtered), v <= 0 {
            discountError = "El descuento debe ser mayor a 0."
        } else if let v = Int(filtered), v > maxDiscount {
            discountError = "No puede superar el \(maxDiscount)%."
        } else {
            discountError = nil
        }
    }

    func validateDates() {
        dateError = startDate >= endDate
        ? "La fecha de inicio debe ser anterior a la de fin."
        : nil
    }

    func validateProducts() {
        productsError = selectedProductIds.isEmpty ? "Selecciona al menos un producto." : nil
    }

    private func allValid() -> Bool {
        validateDescription()
        validateDiscount()
        validateDates()
        validateProducts()
        return descriptionError == nil &&
               discountError    == nil &&
               dateError        == nil &&
               productsError    == nil
    }

    // MARK: - Guardar
    func savePromotion() async {
        guard allValid() else { return }
        isSubmitting = true
        errorMessage = nil

        do {
            if case .edit(let existing) = mode {
                // ACTUALIZAR — usa el ID preexistente
                let updated = Promotion(
                    id:                   existing.id,          // ← ID de Firestore
                    description:          description.trimmingCharacters(in: .whitespaces),
                    discountPercentage:   Double(discountValue),
                    wholesaleOnly:        wholesaleOnly,
                    startDate:            startDate,
                    endDate:              endDate,
                    isActive:             true,
                    applicableProductIds: Array(selectedProductIds)
                )
                try await promotionDataSource.updatePromotion(updated)
                onSave(updated)

            } else {
                // CREAR — Firestore genera el ID, placeholder temporal
                let placeholder = Promotion(
                    id:                   "",                   // ← vacío, Firestore lo asignará
                    description:          description.trimmingCharacters(in: .whitespaces),
                    discountPercentage:   Double(discountValue),
                    wholesaleOnly:        wholesaleOnly,
                    startDate:            startDate,
                    endDate:              endDate,
                    isActive:             true,
                    applicableProductIds: Array(selectedProductIds)
                )
                // createPromotion retorna la promoción con el ID real
                let created = try await promotionDataSource.createPromotion(placeholder)
                onSave(created)
            }

            savedSuccess = true

        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }
}
