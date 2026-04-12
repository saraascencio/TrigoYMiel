//
//  ProductFormView.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import SwiftUI
import PhotosUI

struct ProductFormView: View {

    @StateObject var viewModel: ProductFormViewModel
    let categories: [ProductCategory]

    @Environment(\.dismiss) private var dismiss

    @State private var photoItem:        PhotosPickerItem? = nil
    @State private var selectedImage:    UIImage?          = nil
    @State private var isUploadingImage: Bool              = false
    @State private var localImageURL:    String            = ""
    @State private var localImageError:  String?           = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // MARK: Imagen
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        ImagePickerPreview(
                            selectedImage:    selectedImage,
                            localImageURL:    localImageURL,
                            isUploadingImage: isUploadingImage,
                            hasError:         localImageError != nil
                        )
                    }
                    .onChange(of: photoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                selectedImage           = uiImage
                                viewModel.selectedImage = uiImage
                                localImageURL           = ""
                                localImageError         = nil
                                viewModel.validateImage()
                            }
                        }
                    }
                    .onChange(of: viewModel.isUploadingImage) { value in
                        isUploadingImage = value
                    }
                    .onChange(of: viewModel.imageError) { value in
                        localImageError = value
                    }

                    if let error = localImageError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // MARK: Nombre — solo letras
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nombre")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        TextField("Ej. Alfajor", text: $viewModel.name)
                            .onChange(of: viewModel.name) { value in
                                viewModel.name = viewModel.filterLettersOnly(value)
                                viewModel.validateName()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        viewModel.nameError != nil
                                        ? Color.red.opacity(0.6)
                                        : Color("ColorPrimary").opacity(0.20),
                                        lineWidth: 1
                                    )
                            )
                        if let error = viewModel.nameError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }

                    // MARK: Descripción — solo letras
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Descripción")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))
                        TextEditor(text: $viewModel.description)
                            .onChange(of: viewModel.description) { value in
                                viewModel.description = viewModel.filterLettersOnly(value)
                            }
                            .frame(minHeight: 90)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
                            )
                            .overlay(alignment: .topLeading) {
                                if viewModel.description.isEmpty {
                                    Text("Breve descripción del producto...")
                                        .font(.subheadline)
                                        .foregroundColor(Color("ColorPrimary").opacity(0.3))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 16)
                                        .allowsHitTesting(false)
                                }
                            }
                    }

                    // MARK: Ingredientes — máximo 6
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ingredientes")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        HStack(spacing: 10) {
                            TextField("Ej. Harina de Trigo", text: $viewModel.ingredientInput)
                                .onChange(of: viewModel.ingredientInput) { value in
                                    viewModel.ingredientInput = viewModel.filterLettersOnly(value)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color("ColorPrimary").opacity(0.20), lineWidth: 1)
                                )

                            Button {
                                viewModel.addIngredient()
                            } label: {
                                Image(systemName: "plus")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                    .frame(width: 46, height: 46)
                                    .background(
                                        viewModel.ingredients.count >= 6
                                        ? Color.gray
                                        : Color("ColorSecondary")
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .disabled(viewModel.ingredients.count >= 6)
                        }

                        HStack {
                            Text("Escribe un ingrediente y presiona +")
                                .font(.caption)
                                .foregroundColor(Color("ColorPrimary").opacity(0.4))
                            Spacer()
                            Text("\(viewModel.ingredients.count)/6")
                                .font(.caption)
                                .foregroundColor(
                                    viewModel.ingredients.count >= 6
                                    ? .red
                                    : Color("ColorPrimary").opacity(0.4)
                                )
                        }

                        if let error = viewModel.ingredientError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }

                        if !viewModel.ingredients.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(viewModel.ingredients, id: \.self) { ingredient in
                                    HStack {
                                        Text(ingredient)
                                            .font(.subheadline)
                                            .foregroundColor(Color("ColorPrimary"))
                                        Spacer()
                                        Button {
                                            viewModel.removeIngredient(ingredient)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(Color("ColorPrimary").opacity(0.3))
                                        }
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color("ColorPrimary").opacity(0.10), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }

                    // MARK: Precio y Stock
                    HStack(spacing: 12) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Precio unitario ($)")
                                .font(.subheadline.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            TextField("0.00", text: $viewModel.price)
                                .keyboardType(.decimalPad)
                                .onChange(of: viewModel.price) { value in
                                    viewModel.price = viewModel.filterDecimalOnly(value)
                                    viewModel.validatePrice()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.priceError != nil
                                            ? Color.red.opacity(0.6)
                                            : Color("ColorPrimary").opacity(0.20),
                                            lineWidth: 1
                                        )
                                )
                            if let error = viewModel.priceError {
                                Text(error).font(.caption).foregroundColor(.red)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Stock inicial")
                                .font(.subheadline.bold())
                                .foregroundColor(Color("ColorPrimary"))
                            TextField("0", text: $viewModel.stock)
                                .keyboardType(.numberPad)
                                .onChange(of: viewModel.stock) { value in
                                    viewModel.stock = viewModel.filterIntOnly(value)
                                    viewModel.validateStock()
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.stockError != nil
                                            ? Color.red.opacity(0.6)
                                            : Color("ColorPrimary").opacity(0.20),
                                            lineWidth: 1
                                        )
                                )
                            if let error = viewModel.stockError {
                                Text(error).font(.caption).foregroundColor(.red)
                            }
                        }
                    }

                    // MARK: Categoría
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categoría")
                            .font(.subheadline.bold())
                            .foregroundColor(Color("ColorPrimary"))

                        if categories.isEmpty {
                            ProgressView()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories) { cat in
                                        FilterChip(
                                            title:      cat.name,
                                            isSelected: viewModel.categoryId == cat.id
                                        ) {
                                            viewModel.categoryId = cat.id
                                            viewModel.validateCategory()
                                        }
                                    }
                                }
                            }
                        }

                        if let error = viewModel.categoryError {
                            Text(error).font(.caption).foregroundColor(.red)
                        }
                    }

                    // MARK: Toggle popular
                    VStack(spacing: 12) {
                        Toggle(isOn: $viewModel.isPopular) {
                            Text("Marcar como popular")
                                .font(.subheadline)
                                .foregroundColor(Color("ColorPrimary"))
                        }
                        .tint(Color("ColorSecondary"))
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // MARK: Error general
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: Botón guardar
                    Button {
                        Task { await viewModel.save() }
                    } label: {
                        Group {
                            if viewModel.isSubmitting || isUploadingImage {
                                ProgressView().tint(.white)
                            } else {
                                Text(viewModel.isEditing ? "Guardar cambios" : "Crear producto")
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
                    .disabled(viewModel.isSubmitting || isUploadingImage)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .background(Color("ColorBackground").ignoresSafeArea())
            .navigationTitle(viewModel.isEditing ? "Editar producto" : "Crear producto")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(Color("ColorPrimary"))
                }
            }
        }
        .onAppear {
            viewModel.prefillFirstCategory(categories)
            localImageURL = viewModel.imageURL
        }
    }
}

// MARK: - ImagePickerPreview

struct ImagePickerPreview: View {

    let selectedImage:    UIImage?
    let localImageURL:    String
    let isUploadingImage: Bool
    let hasError:         Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    hasError
                    ? Color.red.opacity(0.6)
                    : Color("ColorPrimary").opacity(0.3),
                    style: StrokeStyle(lineWidth: 1.5, dash: [6])
                )
                .frame(height: 160)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color("ColorAccent").opacity(0.08))
                )

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            } else if !localImageURL.isEmpty {
                AsyncImage(url: URL(string: localImageURL)) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 36))
                            .foregroundColor(Color("ColorPrimary").opacity(0.3))
                    default:
                        ProgressView()
                    }
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundColor(Color("ColorPrimary").opacity(0.4))
                    Text("Toca para cargar imagen")
                        .font(.caption)
                        .foregroundColor(Color("ColorPrimary").opacity(0.4))
                }
            }

            if isUploadingImage {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.black.opacity(0.3))
                    .frame(height: 160)
                    .overlay(ProgressView().tint(.white))
            }
        }
    }
}
