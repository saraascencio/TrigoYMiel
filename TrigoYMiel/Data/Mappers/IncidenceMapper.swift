//
//  IncidenceMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

// Convierte entre [String: Any] de Firestore y el Domain Entity Incidence.
struct IncidenceMapper {
    
    // Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Incidence {
        guard
            let userId = data["userId"] as? String,
            let orderId = data["orderId"] as? String,
            let typeRaw = data["type"] as? String,
            let type = IncidenceType(rawValue: typeRaw),
            let channelRaw = data["channel"] as? String,
            let channel = ContactChannel(rawValue: channelRaw),
            let description = data["description"] as? String,
            let createdTS = data["createdAt"] as? Timestamp,
            let statusRaw = data["status"] as? String,
            let status = IncidenceStatus(rawValue: statusRaw)
        else {
            throw AppError.decodingError
        }
        
        let resolvedTS = data["resolvedAt"] as? Timestamp
        let adminId = data["adminId"] as? String
        let evidenceURL = data["evidenceURL"] as? String
        let resolution = data["resolution"] as? String
        
        return Incidence(
            id: id,
            userId: userId,
            orderId: orderId,
            adminId: adminId,
            type: type,
            channel: channel,
            description: description,
            evidenceURL: evidenceURL,
            createdAt: createdTS.dateValue(),
            status: status,
            resolution: resolution,
            resolvedAt: resolvedTS?.dateValue()
        )
    }
    
    // Domain → Firestore
    static func toFirestore(_ incidence: Incidence) -> [String: Any] {
        var data: [String: Any] = [
            "userId": incidence.userId,
            "orderId": incidence.orderId,
            "type": incidence.type.rawValue,
            "channel": incidence.channel.rawValue,
            "description": incidence.description,
            "createdAt": Timestamp(date: incidence.createdAt),
            "status": incidence.status.rawValue
        ]
        
        if let adminId = incidence.adminId {
            data["adminId"] = adminId
        }
        if let evidenceURL = incidence.evidenceURL {
            data["evidenceURL"] = evidenceURL
        }
        if let resolution = incidence.resolution {
            data["resolution"] = resolution
        }
        if let resolvedAt = incidence.resolvedAt {
            data["resolvedAt"] = Timestamp(date: resolvedAt)
        }
        
        return data
    }
}
