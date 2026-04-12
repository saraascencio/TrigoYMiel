//
//  CloudinaryService.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 9/4/26.
//
import Foundation
import UIKit

// MARK: - CloudinaryService
// Sube imágenes a Cloudinary y devuelve la URL pública.


final class CloudinaryService {

    static let shared = CloudinaryService()

    private let cloudName    = "dnf3hsop9"
    private let uploadPreset = "trigoeymiel_preset"

    private init() {}

    func uploadImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AppError.unknown("No se pudo procesar la imagen.")
        }

        let url = URL(string: "https://api.cloudinary.com/v1_1/\(cloudName)/image/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // upload_preset
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"upload_preset\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(uploadPreset)\r\n".data(using: .utf8)!)

        // file
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"product.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AppError.unknown("Error al subir imagen a Cloudinary.")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let secureURL = json["secure_url"] as? String else {
            throw AppError.unknown("No se pudo obtener la URL de la imagen.")
        }

        return secureURL
    }
}
