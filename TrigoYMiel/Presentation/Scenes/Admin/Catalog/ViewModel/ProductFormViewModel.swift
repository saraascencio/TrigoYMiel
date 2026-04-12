//
//  ProductFormViewModel.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import UIKit
import Combine

enum ProductFormMode {
    case create
    case edit(Product)
}

@MainActor
final class ProductFormViewModel: ObservableObject {

    // MARK: - Fields
    @Published var name:            String = ""
    @Published var description:     String = ""
    @Published var price:           String = ""
    @Published var stock:           String = ""
    @Published var categoryId:      String = ""
    @Published var isAvailable:     Bool   = true
    @Published var isPopular:       Bool   = false
    @Published var ingredientInput: String = ""
    @Published var ingredients:     [String] = []
    @Published var selectedImage:   UIImage? = nil
    @Published var imageURL:        String = ""
    @Published var isUploadingImage: Bool = false

    // MARK: - Errores de validación
    @Published var nameError:       String? = nil
    @Published var priceError:      String? = nil
    @Published var stockError:      String? = nil
    @Published var imageError:      String? = nil
    @Published var categoryError:   String? = nil
    @Published var ingredientError: String? = nil

    // MARK: - State
    @Published var isSubmitting:  Bool    = false
    @Published var errorMessage:  String? = nil

    // MARK: - Config
    let mode: ProductFormMode

    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }

    // MARK: - Dependencies
    private let createProductUseCase: CreateProductUseCase
    private let updateProductUseCase: UpdateProductUseCase
    private let deleteProductUseCase: DeleteProductUseCase
    private let onSave: (Product) -> Void

    init(
        mode:                 ProductFormMode,
        createProductUseCase: CreateProductUseCase,
        updateProductUseCase: UpdateProductUseCase,
        deleteProductUseCase: DeleteProductUseCase,
        onSave:               @escaping (Product) -> Void
    ) {
        self.mode                 = mode
        self.createProductUseCase = createProductUseCase
        self.updateProductUseCase = updateProductUseCase
        self.deleteProductUseCase = deleteProductUseCase
        self.onSave               = onSave
        prefill()
    }

    // MARK: - Filtros de input

    /// Solo letras, espacios y acentos — bloquea números y símbolos
    func filterLettersOnly(_ value: String) -> String {
        value.filter { $0.isLetter || $0.isWhitespace }
    }

    /// Solo números enteros positivos
    func filterIntOnly(_ value: String) -> String {
        value.filter { $0.isNumber }
    }

    /// Solo números decimales (permite un punto)
    func filterDecimalOnly(_ value: String) -> String {
        var result    = value.filter { $0.isNumber || $0 == "." }
        let dotCount  = result.filter { $0 == "." }.count
        if dotCount > 1 {
            // Elimina el último punto extra
            if let lastDot = result.lastIndex(of: ".") {
                result.remove(at: lastDot)
            }
        }
        return result
    }

    // MARK: - Validaciones en tiempo real

    func validateName() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            nameError = "El nombre es obligatorio."
        } else if trimmed.count < 3 {
            nameError = "El nombre debe tener al menos 3 caracteres."
        } else {
            nameError = nil
        }
    }

    func validatePrice() {
        if price.isEmpty {
            priceError = "El precio es obligatorio."
        } else if let value = Double(price), value <= 0 {
            priceError = "El precio debe ser mayor a 0."
        } else if Double(price) == nil {
            priceError = "Ingresa un precio válido."
        } else {
            priceError = nil
        }
    }

    func validateStock() {
        if stock.isEmpty {
            stockError = "El stock es obligatorio."
        } else if let value = Int(stock), value < 0 {
            stockError = "El stock no puede ser negativo."
        } else if Int(stock) == nil {
            stockError = "Ingresa un stock válido."
        } else {
            stockError = nil
        }
    }

    func validateImage() {
        if selectedImage == nil && imageURL.isEmpty {
            imageError = "La imagen del producto es obligatoria."
        } else {
            imageError = nil
        }
    }

    func validateCategory() {
        if categoryId.isEmpty {
            categoryError = "Selecciona una categoría."
        } else {
            categoryError = nil
        }
    }

    private func validateAll() -> Bool {
        validateName()
        validatePrice()
        validateStock()
        validateImage()
        validateCategory()
        return nameError == nil &&
               priceError == nil &&
               stockError == nil &&
               imageError == nil &&
               categoryError == nil
    }

    // MARK: - Ingredientes

    func addIngredient() {
        let trimmed = ingredientInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if ingredients.count >= 6 {
            ingredientError = "Máximo 6 ingredientes."
            return
        }
        if ingredients.contains(trimmed) {
            ingredientError = "Este ingrediente ya fue agregado."
            return
        }
        ingredients.append(trimmed)
        ingredientInput = ""
        ingredientError = nil
    }

    func removeIngredient(_ ingredient: String) {
        ingredients.removeAll { $0 == ingredient }
        ingredientError = nil
    }

    // MARK: - Imagen

    func uploadImageIfNeeded() async throws -> String {
        guard let image = selectedImage else { return imageURL }
        isUploadingImage = true
        defer { isUploadingImage = false }
        return try await CloudinaryService.shared.uploadImage(image)
    }

    // MARK: - Save

    func save() async {
        guard validateAll() else { return }

        isSubmitting = true
        errorMessage = nil

        do {
            let finalURL = try await uploadImageIfNeeded()
            imageURL     = finalURL
            let product  = buildProduct(imageURL: finalURL)

            if isEditing {
                let updated = try await updateProductUseCase.execute(product)
                onSave(updated)
            } else {
                let created = try await createProductUseCase.execute(product)
                onSave(created)
            }
        } catch let error as AppError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }

        isSubmitting = false
    }

    // MARK: - Helpers

    func prefillFirstCategory(_ categories: [ProductCategory]) {
        guard categoryId.isEmpty, let first = categories.first else { return }
        categoryId = first.id
    }

    private func prefill() {
        guard case .edit(let product) = mode else { return }
        name        = product.name
        description = product.description
        price       = String(product.unitPrice)
        stock       = String(product.stock)
        categoryId  = product.categoryId
        imageURL    = product.imageURL
        isAvailable = product.isAvailable
        isPopular   = product.isPopular
        ingredients = product.ingredients
    }

    private func buildProductId() -> String {
        if case .edit(let p) = mode { return p.id }
        return UUID().uuidString
    }

    private func buildProduct(imageURL: String) -> Product {
        let currentIsAvailable: Bool
        if case .edit(let p) = mode {
            currentIsAvailable = p.isAvailable
        } else {
            currentIsAvailable = true
        }

        return Product(
            id:          buildProductId(),
            name:        name,
            description: description,
            ingredients: ingredients,
            unitPrice:   Double(price)  ?? 0,
            stock:       Int(stock)     ?? 0,
            isAvailable: currentIsAvailable,
            categoryId:  categoryId,
            imageURL:    imageURL,
            isPopular:   isPopular
        )
    }
}
