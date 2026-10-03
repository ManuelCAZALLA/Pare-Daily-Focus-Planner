// ObligationTemplate.swift
import Foundation

struct ObligationTemplate: Identifiable, Hashable {
    let id: String
    let category: LifeAdminCategory
    let title: String
    let contextHint: String?

    init(id: String, category: LifeAdminCategory, title: String, contextHint: String? = nil) {
        self.id = id
        self.category = category
        self.title = title
        self.contextHint = contextHint
    }

    // MARK: - Catálogo base (internacional)

    /// Catálogo neutro, válido en cualquier país.
    /// Cada país sustituye los títulos que no apliquen y añade los suyos (ver `pack(for:)`).
    static let generic: [ObligationTemplate] = [
        // Personal documents
        .init(id: "dni", category: .personalDocuments, title: String(localized: "Documento de identidad")),
        .init(id: "passport", category: .personalDocuments, title: String(localized: "Pasaporte")),
        .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Acta de nacimiento")),
        .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Licencia de conducir")),
        .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta sanitaria")),
        .init(id: "residence_permit", category: .personalDocuments, title: String(localized: "Permiso de residencia")),
        .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado digital")),
        .init(id: "degree_homologation", category: .personalDocuments, title: String(localized: "Título profesional")),

        // Vehicle
        .init(id: "itv", category: .vehicle, title: String(localized: "Revisión vehicular"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
        .init(id: "car_insurance", category: .vehicle, title: String(localized: "Seguro del vehículo")),
        .init(id: "moto_insurance", category: .vehicle, title: String(localized: "Seguro de moto")),
        .init(id: "workshop_review", category: .vehicle, title: String(localized: "Revisión del taller")),
        .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Permiso de circulación")),
        .init(id: "foreign_license", category: .vehicle, title: String(localized: "Licencia de conducir de otro país")),

        // Home
        .init(id: "home_insurance", category: .home, title: String(localized: "Seguro del hogar")),
        .init(id: "rental_contract", category: .home, title: String(localized: "Contrato de alquiler")),
        .init(id: "boiler_review", category: .home, title: String(localized: "Mantenimiento de calderas")),
        .init(id: "fire_extinguisher", category: .home, title: String(localized: "Extintor")),
        .init(id: "energy_certificate", category: .home, title: String(localized: "Certificado energético")),
        .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas de la comunidad")),

        // Health
        .init(id: "annual_checkup", category: .health, title: String(localized: "Revisión médica anual")),
        .init(id: "vaccines", category: .health, title: String(localized: "Vacunas")),
        .init(id: "private_health_insurance", category: .health, title: String(localized: "Seguro médico privado")),
        .init(id: "eye_exam", category: .health, title: String(localized: "Revisión óptica")),
        .init(id: "dentist", category: .health, title: String(localized: "Dentista")),
        .init(id: "gynecology", category: .health, title: String(localized: "Revisión ginecológica")),

        // Finance
        .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de impuestos")),
        .init(id: "credit_card", category: .finance, title: String(localized: "Tarjeta de crédito")),
        .init(id: "life_insurance", category: .finance, title: String(localized: "Seguro de vida")),
        .init(id: "pension_plan", category: .finance, title: String(localized: "Plan de pensiones")),
        .init(id: "annual_subscriptions", category: .finance, title: String(localized: "Suscripciones anuales")),
        .init(id: "freelance_fees", category: .finance, title: String(localized: "Cuotas del trabajo autónomo")),

        // Work
        .init(id: "professional_cert", category: .work, title: String(localized: "Certificaciones profesionales")),
        .init(id: "professional_college", category: .work, title: String(localized: "Colegio profesional")),
        .init(id: "transport_card", category: .work, title: String(localized: "Tarjeta de transporte")),
        .init(id: "work_permit", category: .work, title: String(localized: "Permiso de trabajo")),
        .init(id: "expiring_courses", category: .work, title: String(localized: "Cursos con caducidad")),
    ]

    // MARK: - Consultas

    /// Catálogo del país indicado (el país actual si no se indica).
    static func catalog(for country: TramiteCountry = .current) -> [ObligationTemplate] {
        guard country != .international else { return generic }

        let pack = pack(for: country)
        var result: [ObligationTemplate] = generic.map { pack.overrides[$0.id] ?? $0 }

        for insertion in pack.insertions {
            guard let anchor = result.firstIndex(where: { $0.id == insertion.anchor }) else {
                result.append(contentsOf: insertion.templates)
                continue
            }
            result.insert(contentsOf: insertion.templates, at: anchor + 1)
        }
        return result
    }

    static var all: [ObligationTemplate] { catalog() }

    /// Resuelve el título de un trámite guardado.
    /// Primero busca en el catálogo del país actual y, si el trámite se registró
    /// con otra plantilla (por ejemplo tras cambiar de país), recorre el resto
    /// de catálogos para que ningún trámite guardado desaparezca.
    static func template(forID id: String, country: TramiteCountry = .current) -> ObligationTemplate? {
        let currentCatalog = catalog(for: country)
        if let match = currentCatalog.first(where: { $0.id == id }) { return match }
        for candidate in TramiteCountry.allCases where candidate != country {
            if let match = catalog(for: candidate).first(where: { $0.id == id }) { return match }
        }
        return nil
    }

    // MARK: - Catálogos por país

    struct CountryPack {
        var overrides: [String: ObligationTemplate] = [:]
        var insertions: [Insertion] = []

        struct Insertion {
            let anchor: String
            let templates: [ObligationTemplate]

            init(_ anchor: String, _ templates: ObligationTemplate...) {
                self.anchor = anchor
                self.templates = templates
            }
        }
    }

    static func pack(for country: TramiteCountry) -> CountryPack {
        switch country {
        case .spain: return spainPack
        case .mexico: return mexicoPack
        case .colombia: return colombiaPack
        case .argentina: return argentinaPack
        case .chile: return chilePack
        case .peru: return peruPack
        case .ecuador: return ecuadorPack
        case .unitedKingdom: return unitedKingdomPack
        case .unitedStates: return unitedStatesPack
        case .france: return francePack
        case .germany: return germanyPack
        case .italy: return italyPack
        case .portugal: return portugalPack
        case .international: return CountryPack()
        }
    }

    private static let spainPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "DNI / NIE")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Certificado de nacimiento")),
            "driving_license": .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Carnet de conducir")),
            "fnmt_cert": .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado digital (FNMT)")),
            "degree_homologation": .init(id: "degree_homologation", category: .personalDocuments, title: String(localized: "Título universitario homologado")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "ITV"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "car_insurance": .init(id: "car_insurance", category: .vehicle, title: String(localized: "Seguro del coche")),
            "foreign_license": .init(id: "foreign_license", category: .vehicle, title: String(localized: "Licencia de conducir extranjera")),
            "boiler_review": .init(id: "boiler_review", category: .home, title: String(localized: "Caldera (revisión anual)")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Comunidad de vecinos")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de la Renta")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cuotas de autónomo")),
        ]
    )

    private static let mexicoPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "INE / Credencial de elector")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Seguro de salud (IMSS / ISSSTE)")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Verificación vehicular"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Tarjeta de circulación")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración anual del ISR")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Afore (ahorro para el retiro)")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "curp", category: .personalDocuments, title: String(localized: "CURP (Clave Única de Registro de Población)")),
                  .init(id: "rfc", category: .personalDocuments, title: String(localized: "Constancia de situación fiscal (RFC)"))),
            .init("fnmt_cert",
                  .init(id: "sat_e_firma", category: .personalDocuments, title: String(localized: "e.firma (firma electrónica del SAT)"))),
            .init("circulation_permit",
                  .init(id: "tenencia", category: .vehicle, title: String(localized: "Tenencia vehicular"))),
            .init("hoa_fees",
                  .init(id: "predial", category: .home, title: String(localized: "Predial (impuesto predial)"))),
        ]
    )

    private static let colombiaPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Cédula de ciudadanía")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Registro civil de nacimiento")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Revisión técnica mecánica (RTM)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Licencia de tránsito (matrícula)")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de renta y patrimonio")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "rut", category: .personalDocuments, title: String(localized: "RUT (Registro Único Tributario)"))),
            .init("circulation_permit",
                  .init(id: "soat", category: .vehicle, title: String(localized: "SOAT (seguro obligatorio de accidentes de tránsito)")),
                  .init(id: "pico_y_placa", category: .vehicle, title: String(localized: "Pico y placa"))),
            .init("hoa_fees",
                  .init(id: "predial", category: .home, title: String(localized: "Predial (impuesto predial)"))),
        ]
    )

    private static let argentinaPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "DNI (Documento Nacional de Identidad)")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Partida de nacimiento")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Obra social o prepaga")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "VTV (verificación técnica vehicular)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Cédula del automotor")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas del consorcio")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración jurada de Ganancias y Bienes")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "cuil", category: .personalDocuments, title: String(localized: "CUIL (Clave Única de Identificación Laboral)"))),
            .init("freelance_fees",
                  .init(id: "monotributo", category: .finance, title: String(localized: "Monotributo"))),
        ]
    )

    private static let chilePack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "RUT / Cédula de identidad")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Certificado de nacimiento")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "FONASA o plan de salud (Isapre)")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Revisión técnica de vehículos"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Padrón de vehículos (patente)")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración anual de renta")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Aportes previsionales de independientes")),
        ],
        insertions: [
            .init("pension_plan",
                  .init(id: "afp", category: .finance, title: String(localized: "Cotización de AFP y seguro de cesantía"))),
        ]
    )

    private static let peruPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "DNI (Documento Nacional de Identidad)")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "SIS / EsSalud")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Revisión técnica vehicular"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Tarjeta de propiedad del vehículo")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración jurada del impuesto a la renta")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "ruc", category: .personalDocuments, title: String(localized: "RUC (Registro Único de Contribuyentes)"))),
        ]
    )

    private static let ecuadorPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Cédula de identidad")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "IESS / Seguro Social Campesino")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Revisión vehicular (VTV)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración del impuesto a la renta")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "ruc", category: .personalDocuments, title: String(localized: "RUC (Registro Único de Contribuyentes)"))),
        ]
    )

    private static let unitedKingdomPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Número de cotización (National Insurance number)")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Certificado de nacimiento")),
            "driving_license": .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Carnet de conducir (driving licence)")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta del médico de cabecera (NHS)")),
            "residence_permit": .init(id: "residence_permit", category: .personalDocuments, title: String(localized: "Visa o permiso de residencia (right to rent)")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Inspección del vehículo (MOT)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Documento de matriculación (V5C)")),
            "home_insurance": .init(id: "home_insurance", category: .home, title: String(localized: "Seguro del edificio y del contenido")),
            "rental_contract": .init(id: "rental_contract", category: .home, title: String(localized: "Contrato de arrendamiento (tenancy agreement)")),
            "energy_certificate": .init(id: "energy_certificate", category: .home, title: String(localized: "Certificado de rendimiento energético (EPC)")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas de la comunidad (service charges)")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración del impuesto sobre la renta (Self Assessment)")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cotizaciones de autónomo (National Insurance)")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Pensión de jubilación del Estado y del empleador")),
            "work_permit": .init(id: "work_permit", category: .work, title: String(localized: "Permiso de trabajo (Skilled Worker)")),
        ],
        insertions: [
            .init("hoa_fees",
                  .init(id: "council_tax", category: .home, title: String(localized: "Council tax (impuesto municipal)"))),
        ]
    )

    private static let unitedStatesPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Identificación del estado o pasaporte")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Certificado de nacimiento")),
            "driving_license": .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Licencia de conducir del estado")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta de seguro médico")),
            "residence_permit": .init(id: "residence_permit", category: .personalDocuments, title: String(localized: "Green card o visa")),
            "fnmt_cert": .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado de firma digital")),
            "degree_homologation": .init(id: "degree_homologation", category: .personalDocuments, title: String(localized: "Licencia profesional estatal")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Inspección vehicular y prueba de emisiones"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Matrícula del vehículo")),
            "foreign_license": .init(id: "foreign_license", category: .vehicle, title: String(localized: "Licencia de conducir de otro estado")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas de la asociación de propietarios")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de impuestos federales y estatales")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Impuesto de trabajo por cuenta propia (IRS)")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Plan de jubilación (401k / IRA)")),
            "work_permit": .init(id: "work_permit", category: .work, title: String(localized: "Visa de trabajo")),
        ],
        insertions: [
            .init("dni",
                  .init(id: "ssn", category: .personalDocuments, title: String(localized: "Número de la Seguridad Social"))),
            .init("circulation_permit",
                  .init(id: "vehicle_title", category: .vehicle, title: String(localized: "Título de propiedad del vehículo"))),
            .init("hoa_fees",
                  .init(id: "property_tax", category: .home, title: String(localized: "Impuesto sobre la propiedad"))),
        ]
    )

    private static let francePack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Tarjeta nacional de identidad (CNI)")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta Vitale")),
            "fnmt_cert": .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado electrónico")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Control técnico (CT)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Certificado de matriculación")),
            "energy_certificate": .init(id: "energy_certificate", category: .home, title: String(localized: "Diagnóstico energético (DPE)")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas de copropiedad")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de impuestos (impuesto sobre la renta)")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cotizaciones sociales de los autónomos")),
            "transport_card": .init(id: "transport_card", category: .work, title: String(localized: "Transporte urbano (Navigo)")),
            "work_permit": .init(id: "work_permit", category: .work, title: String(localized: "Permiso de trabajo (Passeport Talent)")),
        ],
        insertions: [
            .init("itv",
                  .init(id: "critair", category: .vehicle, title: String(localized: "Distintivo Crit'Air (zonas de bajas emisiones)"))),
        ]
    )

    private static let germanyPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Documento de identidad (Personalausweis)")),
            "driving_license": .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Carnet de conducir (Führerschein)")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tarjeta sanitaria (Gesundheitskarte)")),
            "fnmt_cert": .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado electrónico")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Inspección vehicular (TÜV)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Certificado de matriculación (Zulassungsbescheinigung)")),
            "boiler_review": .init(id: "boiler_review", category: .home, title: String(localized: "Revisión de calderas y de agua")),
            "energy_certificate": .init(id: "energy_certificate", category: .home, title: String(localized: "Certificado energético (Energieausweis)")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas de la comunidad de propietarios")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración del impuesto sobre la renta")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cotizaciones de autónomo (seguros sociales)")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Plan de pensiones (renta legal)")),
            "professional_college": .init(id: "professional_college", category: .work, title: String(localized: "Cámara profesional (Berufskammer)")),
        ]
    )

    private static let italyPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Carta de identidad electrónica (CIE)")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Tessera sanitaria")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Revisión del vehículo (revisione periodica)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Libretto del vehículo")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Cuotas del condominio")),
            "energy_certificate": .init(id: "energy_certificate", category: .home, title: String(localized: "Certificado energético (APE)")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaración de impuestos (IRPF)")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cotizaciones de autónomo (INPS)")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Plan de pensiones (INPS)")),
            "professional_college": .init(id: "professional_college", category: .work, title: String(localized: "Orden profesional (albo)")),
            "work_permit": .init(id: "work_permit", category: .work, title: String(localized: "Permiso de trabajo (permesso di soggiorno)")),
        ]
    )

    private static let portugalPack = CountryPack(
        overrides: [
            "dni": .init(id: "dni", category: .personalDocuments, title: String(localized: "Cartão de cidadão")),
            "birth_certificate": .init(id: "birth_certificate", category: .personalDocuments, title: String(localized: "Certidão de nascimento")),
            "driving_license": .init(id: "driving_license", category: .personalDocuments, title: String(localized: "Carta de condução")),
            "health_card": .init(id: "health_card", category: .personalDocuments, title: String(localized: "Cartão de saúde (SNS)")),
            "fnmt_cert": .init(id: "fnmt_cert", category: .personalDocuments, title: String(localized: "Certificado digital (Gov.pt)")),
            "itv": .init(id: "itv", category: .vehicle, title: String(localized: "Inspeção periódica obrigatória (IPO)"), contextHint: String(localized: "Suelen tardar 1 semana en dar cita")),
            "circulation_permit": .init(id: "circulation_permit", category: .vehicle, title: String(localized: "Documento único do veículo (DUC)")),
            "hoa_fees": .init(id: "hoa_fees", category: .home, title: String(localized: "Quotas de condomínio")),
            "tax_return": .init(id: "tax_return", category: .finance, title: String(localized: "Declaração de IRS")),
            "freelance_fees": .init(id: "freelance_fees", category: .finance, title: String(localized: "Cotizações de trabalhador independente")),
            "pension_plan": .init(id: "pension_plan", category: .finance, title: String(localized: "Fundo de pensions")),
        ],
        insertions: [
            .init("hoa_fees",
                  .init(id: "imi", category: .home, title: String(localized: "IMI (imposto municipal sobre o imóvel)"))),
        ]
    )
}
