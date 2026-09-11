//
//  PurchasesService.swift
//  Recuerda tus Trámites
//
//  Created by Manuel Cazalla Colmenero on 02/08/2026.

import Foundation
import RevenueCat
import WidgetKit

// MARK: - Constantes

extension String {
    /// Nombre exacto del entitlement en el dashboard de RevenueCat
    static let tramiteProEntitlement = "Recuerda tus Trámites Pro"
    static let legacyProEntitlement = "DaySorted Pro"
}

// MARK: - PurchasesService

/// Singleton Observable que centraliza todo el estado de monetización.
/// Se inyecta en el environment desde TramiteApp y se lee con:
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

    /// Pro Tip: NO ejecutamos trabajo pesado (WidgetKit reload) sincrónicamente en el
    /// `didSet` de customerInfo. Durante una compra StoreKit requiere que el hilo principal
    /// responda con rapidez; bloquearlo aquí puede provocar que la transacción se cancele
    /// silenciosamente ("Purchase was cancelled") como veíamos.
    var customerInfo: CustomerInfo? = nil {
        didSet {
            let newPro = isProActive
            let oldPro = lastProState
            lastProState = newPro

            // Solo propagar cuando el estado Pro realmente cambia (o es el primer valor)
            guard oldPro != newPro || oldPro == nil else { return }

            UserDefaults(suiteName: "group.com.manuelcazalla.recuerdatustramites")?
                .set(newPro, forKey: "isProActive")

            // El reload de widgets se difiere para no bloquear el hilo principal
            // durante una operación de StoreKit en curso.
            DispatchQueue.main.async {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }

    private var lastProState: Bool? = nil

    /// true si existe cualquier entitlement activo o si coincide alguno de los nombres conocidos
    var isProActive: Bool {
        #if DEBUG
        if debugForcePro { return true }
        #endif
        guard let customerInfo else { return false }
        
        // 1. Si el usuario tiene cualquier entitlement activo devuelto por RevenueCat, es Pro
        if !customerInfo.entitlements.active.isEmpty {
            return true
        }

        // 2. Comprobación fallback de nombres específicos de entitlement
        return customerInfo.entitlements[.tramiteProEntitlement]?.isActive == true
            || customerInfo.entitlements[.legacyProEntitlement]?.isActive == true
            || customerInfo.entitlements["pro"]?.isActive == true
            || customerInfo.entitlements["pro_access"]?.isActive == true
            || customerInfo.entitlements["recuerda_tus_tramites_pro"]?.isActive == true
            || customerInfo.entitlements["Recuerda tus Tramites Pro"]?.isActive == true
    }

    /// Control centralizado para la presentación del Paywall en el nivel raíz (evita errores de anclaje de UI en iPadOS)
    var showPaywall = false

    var isLoading = false

    /// Estado de error visible para la UI
    var errorMessage: String? = nil

    /// Para que la UI pueda saber si la carga inicial terminó (evitar pantalla vacía)
    var didCompleteInitialLoad = false

    #if DEBUG
    /// Override de test: fuerza el estado Pro en builds de depuración.
    var debugForcePro = false {
        didSet {
            UserDefaults(suiteName: "group.com.manuelcazalla.recuerdatustramites")?
                .set(isProActive, forKey: "isProActive")
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    #endif

    // MARK: - Carga inicial

    /// Llamar en .task {} de la pantalla raíz o en ContentView.onAppear
    func loadCustomerInfo(retries: Int = 3) async {
        isLoading = true
        defer {
            isLoading = false
            didCompleteInitialLoad = true
        }
        for attempt in 0..<retries {
            do {
                customerInfo = try await Purchases.shared.customerInfo()
                errorMessage = nil
                return
            } catch {
                errorMessage = error.localizedDescription
                if attempt < retries - 1 {
                    try? await Task.sleep(for: .seconds(Double(attempt + 1)))
                }
            }
        }
    }

    // MARK: - Restaurar compras

    @discardableResult
    func restorePurchases(retries: Int = 2) async -> Bool {
        isLoading = true
        defer { isLoading = false }
        for attempt in 0..<retries {
            do {
                customerInfo = try await Purchases.shared.restorePurchases()
                errorMessage = nil
                return isProActive
            } catch {
                errorMessage = error.localizedDescription
                if attempt < retries - 1 {
                    try? await Task.sleep(for: .seconds(Double(attempt + 1)))
                }
            }
        }
        return false
    }
}
