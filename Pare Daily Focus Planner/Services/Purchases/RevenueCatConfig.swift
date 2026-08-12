//
//  RevenueCatConfig.swift
//  Pare Daily Focus Planner

import Foundation

enum RevenueCatConfig {
    #if DEBUG
    static let apiKey = "test_fJpOtRkRhnbdRhEBVtGhcmMKXwa"
    #else
    /// Clave pública de producción de RevenueCat (Project Settings → API keys → Apple App Store).
    /// Sustituir antes de subir a App Store.
    static let apiKey = "appl_PEGAR_CLAVE_PRODUCCION_AQUI"
    #endif
}
