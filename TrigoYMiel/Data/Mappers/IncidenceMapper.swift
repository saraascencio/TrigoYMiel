//
//  IncidenceMapper.swift
//  TrigoYMiel
//
//  Created by Sara Ascencio on 31/3/26.
//
import Foundation
import FirebaseFirestore

struct IncidenceMapper {

    // MARK: Firestore → Domain
    static func toDomain(from data: [String: Any], id: String) throws -> Incidence {

        // Campos críticos — si faltan sí lanza error
        guard
            let userId      = data["userId"]      as? String,
            let orderId     = data["orderId"]      as? String,
            let description = data["description"] as? String,
            let createdTS   = data["createdAt"]   as? Timestamp
        else {
            throw AppError.decodingError
        }

        // Enums con fallback — si el valor no coincide usa el default
        let typeRaw    = data["type"]    as? String ?? IncidenceType.query.rawValue
        let type       = IncidenceType(rawValue: typeRaw) ?? .query

        let channelRaw = data["channel"] as? String ?? ContactChannel.chat.rawValue
        let channel    = ContactChannel(rawValue: channelRaw) ?? .chat

        let statusRaw  = data["status"]  as? String ?? IncidenceStatus.open.rawValue
        let status     = IncidenceStatus(rawValue: statusRaw) ?? .open

 
        let evidenceURL = data["evidenceURL"] as? String
        let resolvedTS  = data["resolvedAt"] as? Timestamp

        return Incidence(
            id:          id,
            userId:      userId,
            orderId:     orderId,
            adminId:     data["adminId"]    as? String,
            type:        type,
            channel:     channel,
            description: description,
            evidenceURL: evidenceURL,
            createdAt:   createdTS.dateValue(),
            status:      status,
            resolution:  data["resolution"] as? String,
            resolvedAt:  resolvedTS?.dateValue()
        )
    }

    // MARK: Domain → Firestore
    static func toFirestore(_ incidence: Incidence) -> [String: Any] {
        var data: [String: Any] = [
            "userId":      incidence.userId,
            "orderId":     incidence.orderId,
            "type":        incidence.type.rawValue,
            "channel":     incidence.channel.rawValue,
            "description": incidence.description,
            "createdAt":   Timestamp(date: incidence.createdAt),
            "status":      incidence.status.rawValue
        ]

        if let adminId     = incidence.adminId     { data["adminId"]     = adminId }
        if let evidenceURL = incidence.evidenceURL { data["evidenceURL"] = evidenceURL }
        if let resolution  = incidence.resolution  { data["resolution"]  = resolution }
        if let resolvedAt  = incidence.resolvedAt  { data["resolvedAt"]  = Timestamp(date: resolvedAt) }

        return data
    }
}
