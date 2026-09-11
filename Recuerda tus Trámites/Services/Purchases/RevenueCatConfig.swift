//
//  RevenueCatConfig.swift
//  Recuerda tus Trámites

import Foundation

enum RevenueCatConfig {
    #if DEBUG
    /// Clave pública de DEVELOPMENT de RevenueCat (Project Settings → API keys → Apple App Store → Public SDK Key).
    /// Esta clave debe corresponder a un proyecto de RevenueCat cuyo bundle ID de App Store
    /// coincida EXACTAMENTE con el de esta app: com.manuelcazallacolmenero.recuerdatustramites
    /// Si la clave no coincide con el bundle ID, la compra en sandbox devuelve
    /// Error 11 (InvalidCredentialsError / Invalid API Key) y Apple rechaza la app (Guideline 3.1/2.3).
    static let apiKey = "appl_CiHojapWnLhRKCnlPyEhUMxmhPK"
    #else
    /// Clave pública de PRODUCCIÓN de RevenueCat (Project Settings → API keys → Apple App Store → Public SDK Key).
    ///
    /// ⚠️ IMPORTANTE para superar la revisión de Apple (Guideline 3.1/2.3):
    /// 1. Esta clave debe obtenerse de un proyecto de RevenueCat cuyo App Store bundle ID sea
    ///    EXACTAMENTE "com.manuelcazallacolmenero.recuerdatustramites".
    /// 2. Si la app viene de un renombrado (antes DaySorted), verifica que el bundle ID en RevenueCat
    ///    esté actualizado. Un desajuste provoca "Error 11: There was a credentials issue".
    /// 3. Sustituir este valor por la clave pública real antes de subir a App Store Connect.
    static let apiKey = "appl_CiHojapWnLhRKCnlPyEhUMxmhPK"
    #endif
}
