//
//  GeofenceService.swift
//  TrigoYMiel
//
//  Created by Walter Gonzalez on 7/5/26.
//
//  Servicio de infraestructura que monitorea la proximidad al local
//  mediante CoreLocation y dispara notificaciones locales (UNUserNotifications).
//
//  Flujo:
//  1. ClientTabCoordinator llama a GeofenceService.shared.configure(user:)
//     y luego a startMonitoring() al entrar en escena.
//  2. iOS dispara didEnterRegion cuando el dispositivo cruza el radio de 200 m.
//  3. El servicio consulta PromotionFirestoreDataSource, filtra por tier del usuario
//     y manda una notificación local personalizada.
//  4. En Xcode se simula con el archivo BakeryApproach.gpx o llamando simulateEntry().

import CoreLocation
import UserNotifications
import Foundation

// MARK: - GeofenceService

final class GeofenceService: NSObject {

    // MARK: Singleton — mismo patrón que CloudinaryService
    static let shared = GeofenceService()

    // MARK: Configuración del local — ajusta al local real
    private let bakeryCoordinate = CLLocationCoordinate2D(
        latitude:  13.6929,   // ← reemplaza con coordenadas reales
        longitude: -89.2182
    )
    private let geofenceRadius: CLLocationDistance = 200  // metros
    private let regionIdentifier = "com.trigomiel.bakery_region"

    // MARK: Usuario activo — se inyecta desde ClientTabCoordinator
    private var currentUser: User?

    // MARK: Dependencia de datos
    private let promotionDataSource = PromotionFirestoreDataSource()

    // MARK: Privados
    private let locationManager = CLLocationManager()
    private var isMonitoring = false
    private var hasNotifiedThisSession = false  // ← NUEVO

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        UNUserNotificationCenter.current().delegate = self  // ← NUEVO
    }

    // MARK: - API pública

    /// Inyecta el usuario activo antes de iniciar el monitoreo.
    /// Llama desde ClientTabCoordinator.onAppear.
    func configure(user: User) {
        currentUser = user
    }

    /// Registra la región circular del local y solicita permisos.
    func startMonitoring() {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else { return }
        guard !isMonitoring else { return }

        requestNotificationPermission()
        locationManager.requestWhenInUseAuthorization()

        let region = CLCircularRegion(
            center: bakeryCoordinate,
            radius: geofenceRadius,
            identifier: regionIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit  = false

        locationManager.startMonitoring(for: region)
        isMonitoring = true
    }

    /// Detiene el monitoreo. Llama desde ClientTabCoordinator.onDisappear.
    func stopMonitoring() {
        locationManager.monitoredRegions
            .filter { $0.identifier == regionIdentifier }
            .forEach { locationManager.stopMonitoring(for: $0) }
        isMonitoring = false
        hasNotifiedThisSession = false  // ← NUEVO
    }

    // MARK: - Simulación para QA / Debug
    /// Dispara la misma lógica que didEnterRegion sin necesidad de GPS.
    /// Úsalo con el archivo .gpx en Xcode o con un botón #if DEBUG.
    func simulateEntry() {
        Task { await handleRegionEntry() }
    }

    // MARK: - Lógica interna

    private func handleRegionEntry() async {
        guard let user = currentUser else { return }

        do {
            let allPromos = try await promotionDataSource.getActivePromotions()
            let visible   = filterPromotions(allPromos, for: user)

            if let promo = visible.first {
                schedulePromoNotification(promo, for: user)
            } else {
                scheduleGenericNearbyNotification()
            }
        } catch {
            // Si Firestore falla, mandamos igualmente la notificación genérica
            scheduleGenericNearbyNotification()
        }
    }

    private func filterPromotions(_ promotions: [Promotion], for user: User) -> [Promotion] {
        promotions.filter { promo in
            guard promo.isCurrentlyValid else { return false }
            // Las promos wholesaleOnly solo son visibles para mayoristas
            if promo.wholesaleOnly { return user.tier == .wholesale }
            return true
        }
    }

    // MARK: - Builders de notificación

    private func schedulePromoNotification(_ promo: Promotion, for user: User) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.userInfo = ["promotionId": promo.id ?? ""]

        if promo.wholesaleOnly && user.tier == .wholesale {
            content.title = "🎉 Oferta exclusiva para mayoristas"
            content.body  = "\(promo.description) — \(promo.formattedDiscount) de descuento. ¡Estás cerca, pasa por tu pedido!"
        } else {
            content.title = "¡Oferta en Trigo y Miel! 🥐"
            content.body  = "\(promo.description) — \(promo.formattedDiscount) de descuento hoy."
        }

        deliver(content: content, identifier: "promo_\(promo.id ?? UUID().uuidString)")
    }

    private func scheduleGenericNearbyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "¡Estás cerca de Trigo y Miel! 🏪"
        content.body  = "Descubre nuestros productos frescos de hoy. ¡Te esperamos!"
        content.sound = .default
        deliver(content: content, identifier: "nearby_generic")
    }

    // MARK: - Entrega inmediata

    private func deliver(content: UNMutableNotificationContent, identifier: String) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
}

// MARK: - CLLocationManagerDelegate

extension GeofenceService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == regionIdentifier else { return }
        guard !hasNotifiedThisSession else { return }  // ← NUEVO
        hasNotifiedThisSession = true                  // ← NUEVO
        Task { await handleRegionEntry() }
    }

    func locationManager(_ manager: CLLocationManager,
                         monitoringDidFailFor region: CLRegion?,
                         withError error: Error) {
        print("[GeofenceService] Error monitoreando región: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startMonitoring()
        default:
            break
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension GeofenceService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])  // muestra el banner aunque la app esté abierta
    }
}
