//
//  PurchasesService.swift
//  Pare Daily Focus Planner
//
//  Created by Manuel Cazalla Colmenero on 02/08/2026.

import Foundation
import RevenueCat
import WidgetKit

// MARK: - Constantes

extension String {
    /// Nombre exacto del entitlement en el dashboard de RevenueCat
    static let pareProEntitlement = "Pare Pro"
}

// MARK: - PurchasesService

/// Singleton Observable que centraliza todo el estado de monetización.
/// Se inyecta en el environment desde PareApp y se lee con:
///   @Environment(PurchasesService.self) private var purchases
@Observable
@MainActor
final class PurchasesService {

    static let shared = PurchasesService()
    private init() {
        // Escuchar actualizaciones de CustomerInfo en tiempo real
        // (por ejemplo, cuando el usuario gestiona su sub desde Ajustes de iOS)
        Task {
            for await info in Purchases.shared.customerInfoStream {
                self.customerInfo = info
            }
        }
    }

    // MARK: - Estado público

    var customerInfo: CustomerInfo? = nil {
        didSet {
            UserDefaults(suiteName: "group.com.manuelcazalla.pare")?
                .set(isProActive, forKey: "isProActive")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// true si el entitlement "Pare Pro" está activo
    var isProActive: Bool {
        #if DEBUG
        if debugForcePro { return true }
        #endif
        return customerInfo?.entitlements[.pareProEntitlement]?.isActive == true
    }

    var isLoading = false
    var errorMessage: String? = nil

    #if DEBUG
    /// Override de test: fuerza el estado Pro en builds de depuración.
    var debugForcePro = false {
        didSet {
            UserDefaults(suiteName: "group.com.manuelcazalla.pare")?
                .set(isProActive, forKey: "isProActive")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    #endif

    // MARK: - Carga inicial

    /// Llamar en .task {} de la pantalla raíz o en ContentView.onAppear
    func loadCustomerInfo() async {
        do {
            customerInfo = try await Purchases.shared.customerInfo()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Restaurar compras

    @discardableResult
    func restorePurchases() async -> Bool {
        isLoading = true
        defer { isLoading = false }
        do {
            customerInfo = try await Purchases.shared.restorePurchases()
            return isProActive
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
