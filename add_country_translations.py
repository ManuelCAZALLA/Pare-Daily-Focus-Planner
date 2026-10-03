#!/usr/bin/env python3
"""Añade las traducciones de los catálogos por país y completa las claves que faltaban.

Aplica las traducciones a los dos catálogos de localisation (app y widget),
porque el widget comparte las plantillas con la app.

Uso:  python3 add_country_translations.py
"""

import json
import pathlib
import unicodedata

ROOT = pathlib.Path(__file__).resolve().parent
FILES = [
    ROOT / "Recuerda tus Trámites" / "Resources" / "Localizable.xcstrings",
    ROOT / "TramiteWidgets" / "Resources" / "Localizable.xcstrings",
]

LANGS = ["en", "fr", "de", "it", "pt", "ar"]

T = {
    # ── Claves que faltaban en los 6 idiomas ────────────────────────────────
    "Esta semana": {
        "en": "This week", "fr": "Cette semaine", "de": "Diese Woche",
        "it": "Questa settimana", "pt": "Esta semana", "ar": "هذا الأسبوع",
    },
    "Exportar PDF": {
        "en": "Export PDF", "fr": "Exporter en PDF", "de": "Als PDF exportieren",
        "it": "Esporta PDF", "pt": "Exportar PDF", "ar": "تصدير PDF",
    },
    "Mañana · Noche": {
        "en": "Tomorrow · Evening", "fr": "Demain · Soir", "de": "Morgen · Abend",
        "it": "Domani · Sera", "pt": "Amanhã · Noite", "ar": "غدًا · المساء",
    },
    "No se pudo completar la compra": {
        "en": "The purchase could not be completed", "fr": "L'achat n'a pas pu être finalisé",
        "de": "Der Kauf konnte nicht abgeschlossen werden",
        "it": "Non è stato possibile completare l'acquisto",
        "pt": "Não foi possível concluir a compra", "ar": "تعذّر إتمام عملية الشراء",
    },
    "No se pudo completar la rutina": {
        "en": "The routine could not be completed", "fr": "La routine n'a pas pu être terminée",
        "de": "Die Routine konnte nicht abgeschlossen werden",
        "it": "Non è stato possibile completare la routine",
        "pt": "Não foi possível concluir a rotina", "ar": "تعذّر إتمام الروتين",
    },
    "No se pudo guardar la rutina. Inténtalo de nuevo.": {
        "en": "The routine could not be saved. Try again.", "fr": "Impossible d'enregistrer la routine. Réessayez.",
        "de": "Die Routine konnte nicht gespeichert werden. Versuche es erneut.",
        "it": "Non è stato possibile salvare la routine. Riprova.",
        "pt": "Não foi possível guardar a rotina. Tente novamente.",
        "ar": "تعذّر حفظ الروتين. حاول مرة أخرى.",
    },
    "No se pudo programar el aviso de rutina.": {
        "en": "The routine reminder could not be scheduled.", "fr": "L'alerte de routine n'a pas pu être programmée.",
        "de": "Die Routine-Erinnerung konnte nicht geplant werden.",
        "it": "Non è stato possibile programmare l'avviso della routine.",
        "pt": "Não foi possível agendar o aviso da rotina.",
        "ar": "تعذّر جدولة تذكير الروتين.",
    },
    "OK": {lang: "OK" for lang in LANGS},

    # ── PDF exportado ───────────────────────────────────────────────────────
    "Titular": {
        "en": "Holder", "fr": "Titulaire", "de": "Inhaber", "it": "Intestatario",
        "pt": "Titular", "ar": "صاحب المستند",
    },
    "Documentación necesaria": {
        "en": "Required documents", "fr": "Documents nécessaires", "de": "Erforderliche Unterlagen",
        "it": "Documenti necessari", "pt": "Documentação necessária", "ar": "المستندات المطلوبة",
    },
    "Notas": {
        "en": "Notes", "fr": "Notes", "de": "Notizen", "it": "Note", "pt": "Notas", "ar": "ملاحظات",
    },
    "Generado el %@": {
        "en": "Generated on %@", "fr": "Généré le %@", "de": "Erstellt am %@",
        "it": "Generato il %@", "pt": "Gerado em %@", "ar": "تم الإنشاء في %@",
    },

    # ── Catálogo genérico ───────────────────────────────────────────────────
    "Documento de identidad": {
        "en": "ID document", "fr": "Pièce d'identité", "de": "Ausweisdokument",
        "it": "Documento d'identità", "pt": "Documento de identificação", "ar": "وثيقة الهوية",
    },
    "Acta de nacimiento": {
        "en": "Birth certificate", "fr": "Acte de naissance", "de": "Geburtsurkunde",
        "it": "Atto di nascita", "pt": "Certidão de nascimento", "ar": "شهادة الميلاد",
    },
    "Licencia de conducir": {
        "en": "Driving license", "fr": "Permis de conduire", "de": "Führerschein",
        "it": "Patente di guida", "pt": "Carta de condução", "ar": "رخصة القيادة",
    },
    "Certificado digital": {
        "en": "Digital certificate", "fr": "Certificat numérique", "de": "Digitales Zertifikat",
        "it": "Certificato digitale", "pt": "Certificado digital", "ar": "شهادة رقمية",
    },
    "Título profesional": {
        "en": "Professional degree", "fr": "Diplôme professionnel", "de": "Berufsqualifikation",
        "it": "Titolo professionale", "pt": "Habilitação profissional", "ar": "المؤهل المهني",
    },
    "Revisión vehicular": {
        "en": "Vehicle inspection", "fr": "Contrôle technique du véhicule", "de": "Fahrzeugprüfung",
        "it": "Revisione del veicolo", "pt": "Inspeção do veículo", "ar": "فحص المركبة",
    },
    "Seguro del vehículo": {
        "en": "Vehicle insurance", "fr": "Assurance véhicule", "de": "Fahrzeugversicherung",
        "it": "Assicurazione auto", "pt": "Seguro do veículo", "ar": "تأمين المركبة",
    },
    "Licencia de conducir de otro país": {
        "en": "Foreign driving license", "fr": "Permis de conduire étranger", "de": "Ausländischer Führerschein",
        "it": "Patente estera", "pt": "Carta de condução estrangeira", "ar": "رخصة قيادة أجنبية",
    },
    "Mantenimiento de calderas": {
        "en": "Boiler maintenance", "fr": "Entretien de la chaudière", "de": "Kesselwartung",
        "it": "Manutenzione caldaia", "pt": "Manutenção da caldera", "ar": "صيانة الغلاية",
    },
    "Cuotas de la comunidad": {
        "en": "Community fees", "fr": "Charges de copropriété", "de": "Hausgeld",
        "it": "Spese condominiali", "pt": "Quotas da comunidade", "ar": "رسوم المجمع",
    },
    "Declaración de impuestos": {
        "en": "Tax return", "fr": "Déclaration de revenus", "de": "Steuererklärung",
        "it": "Dichiarazione dei redditi", "pt": "Declaração de impostos", "ar": "الإقرار الضريبي",
    },
    "Cuotas del trabajo autónomo": {
        "en": "Self-employed contributions", "fr": "Cotisations d'indépendant", "de": "Beiträge zur Selbstständigkeit",
        "it": "Contributi da autonomo", "pt": "Cotizações do trabalhador independente", "ar": "رسوم العمل الحر",
    },

    # ── Países ───────────────────────────────────────────────────────────────
    "España": {
        "en": "Spain", "fr": "Espagne", "de": "Spanien", "it": "Spagna", "pt": "Espanha", "ar": "إسبانيا",
    },
    "México": {
        "en": "Mexico", "fr": "Mexique", "de": "Mexiko", "it": "Messico", "pt": "México", "ar": "المكسيك",
    },
    "Colombia": {
        "en": "Colombia", "fr": "Colombie", "de": "Kolumbien", "it": "Colombia", "pt": "Colômbia", "ar": "كولومبيا",
    },
    "Argentina": {
        "en": "Argentina", "fr": "Argentine", "de": "Argentinien", "it": "Argentina", "pt": "Argentina", "ar": "الأرجنتين",
    },
    "Chile": {
        "en": "Chile", "fr": "Chili", "de": "Chile", "it": "Cile", "pt": "Chile", "ar": "تشيلي",
    },
    "Perú": {
        "en": "Peru", "fr": "Pérou", "de": "Peru", "it": "Perù", "pt": "Peru", "ar": "بيرو",
    },
    "Ecuador": {
        "en": "Ecuador", "fr": "Équateur", "de": "Ecuador", "it": "Ecuador", "pt": "Equador", "ar": "الإكوادور",
    },
    "Reino Unido": {
        "en": "United Kingdom", "fr": "Royaume-Uni", "de": "Vereinigtes Königreich",
        "it": "Regno Unito", "pt": "Reino Unido", "ar": "المملكة المتحدة",
    },
    "Estados Unidos": {
        "en": "United States", "fr": "États-Unis", "de": "Vereinigte Staaten",
        "it": "Stati Uniti", "pt": "Estados Unidos", "ar": "الولايات المتحدة",
    },
    "Francia": {
        "en": "France", "fr": "France", "de": "Frankreich", "it": "Francia", "pt": "França", "ar": "فرنسا",
    },
    "Alemania": {
        "en": "Germany", "fr": "Allemagne", "de": "Deutschland", "it": "Germania", "pt": "Alemanha", "ar": "ألمانيا",
    },
    "Italia": {
        "en": "Italy", "fr": "Italie", "de": "Italien", "it": "Italia", "pt": "Itália", "ar": "إيطاليا",
    },
    "Portugal": {
        "en": "Portugal", "fr": "Portugal", "de": "Portugal", "it": "Portogallo", "pt": "Portugal", "ar": "البرتغال",
    },
    "Internacional": {
        "en": "International", "fr": "International", "de": "International",
        "it": "Internazionale", "pt": "Internacional", "ar": "دولي",
    },

    # ── Interfaz del selector de país ───────────────────────────────────────
    "Trámites de %@": {
        "en": "Obligations in %@", "fr": "Procédures pour %@", "de": "Vorgänge in %@",
        "it": "Adempimenti in %@", "pt": "Procedimentos em %@", "ar": "إجراءات %@",
    },
    "settings.tramites": {
        "en": "Obligations", "fr": "Procédures", "de": "Vorgänge", "it": "Adempimenti",
        "pt": "Procedimentos", "ar": "الإجراءات",
    },
    "settings.country.title": {
        "en": "Country for your obligations", "fr": "Pays de vos procédures",
        "de": "Land für Ihre Vorgänge", "it": "Paese per i tuoi adempimenti",
        "pt": "País dos seus procedimentos", "ar": "بلد إجراءاتك",
    },
    "settings.country.detail": {
        "en": "We adapt the paperwork to your country", "fr": "Nous adaptons les démarches à votre pays",
        "de": "Wir passen die Vorgänge an Ihr Land an", "it": "Adattiamo gli adempimenti al tuo paese",
        "pt": "Adaptamos os procedimentos ao seu país", "ar": "نكيّف الإجراءات حسب بلدك",
    },
    # Etiquetas de sección resueltas en runtime con String.LocalizationValue
    "Sugerencias rápidas": {
        "en": "Quick suggestions", "fr": "Suggestions rapides", "de": "Schnellvorschläge",
        "it": "Suggerimenti rapidi", "pt": "Sugestões rápidas", "ar": "اقتراحات سريعة",
    },
    "Prioridad": {
        "en": "Priority", "fr": "Priorité", "de": "Priorität", "it": "Priorità",
        "pt": "Prioridade", "ar": "الأولوية",
    },
    "Fecha": {
        "en": "Date", "fr": "Date", "de": "Datum", "it": "Data",
        "pt": "Data", "ar": "التاريخ",
    },
    "Hora": {
        "en": "Time", "fr": "Heure", "de": "Uhrzeit", "it": "Ora",
        "pt": "Hora", "ar": "الوقت",
    },
    "Repetir": {
        "en": "Repeat", "fr": "Répéter", "de": "Wiederholen", "it": "Ripeti",
        "pt": "Repetir", "ar": "تكرار",
    },

    # ── México ──────────────────────────────────────────────────────────────
    "INE / Credencial de elector": {
        "en": "INE / Voter ID", "fr": "INE / carte d'électeur", "de": "INE / Wählerausweis",
        "it": "INE / tessera elettorale", "pt": "INE / cartão de eleitor", "ar": "INE / بطاقة الناخب",
    },
    "Seguro de salud (IMSS / ISSSTE)": {
        "en": "Health insurance (IMSS / ISSSTE)", "fr": "Assurance maladie (IMSS / ISSSTE)",
        "de": "Krankenversicherung (IMSS / ISSSTE)", "it": "Assicurazione sanitaria (IMSS / ISSSTE)",
        "pt": "Seguro de saúde (IMSS / ISSSTE)", "ar": "التأمين الصحي (IMSS / ISSSTE)",
    },
    "Verificación vehicular": {
        "en": "Vehicle verification", "fr": "Vérification du véhicule", "de": "Fahrzeugverifikation",
        "it": "Verifica del veicolo", "pt": "Verificação do veículo", "ar": "تحقّق المركبة",
    },
    "Tarjeta de circulación": {
        "en": "Vehicle registration", "fr": "Carte grise", "de": "Fahrzeugschein",
        "it": "Carta di circolazione", "pt": "Documento do veículo", "ar": "بطاقة المركبة",
    },
    "Declaración anual del ISR": {
        "en": "Annual income tax return (ISR)", "fr": "Déclaration annuelle d'impôt sur le revenu (ISR)",
        "de": "Jährliche Einkommensteuererklärung (ISR)", "it": "Dichiarazione annuale delle imposte (IR)",
        "pt": "Declaração anual do imposto de renda (ISR)", "ar": "الإقرار الضريبي السنوي (ISR)",
    },
    "Afore (ahorro para el retiro)": {
        "en": "Afore (retirement savings)", "fr": "Afore (épargne retraite)", "de": "Afore (Altersvorsorge)",
        "it": "Afore (risparmio previdenziale)", "pt": "Afore (poupança de aposentadoria)", "ar": "أفور (مدخرات التقاعد)",
    },
    "CURP (Clave Única de Registro de Población)": {
        "en": "CURP (Unique Population Registry Code)", "fr": "CURP (clé unique d'enregistrement de la population)",
        "de": "CURP (einheitlicher Bevölkerungsregister-Schlüssel)",
        "it": "CURP (codice univoco del registro della popolazione)",
        "pt": "CURP (chave única de registo populacional)", "ar": "CURP (رمز السجل السكاني الفريد)",
    },
    "Constancia de situación fiscal (RFC)": {
        "en": "Tax status certificate (RFC)", "fr": "Attestation de situation fiscale (RFC)",
        "de": "Steuerbescheinigung (RFC)", "it": "Attestato di posizione fiscale (RFC)",
        "pt": "Comprovante de situação fiscal (RFC)", "ar": "شهادة الوضع الضريبي (RFC)",
    },
    "e.firma (firma electrónica del SAT)": {
        "en": "e.firma (SAT electronic signature)", "fr": "e.firma (signature électronique du SAT)",
        "de": "e.firma (elektronische SAT-Signatur)", "it": "e.firma (firma elettronica del SAT)",
        "pt": "e.firma (assinatura eletrónica do SAT)", "ar": "e.firma (التوقيع الإلكتروني لـ SAT)",
    },
    "Tenencia vehicular": {
        "en": "Vehicle registration renewal", "fr": "Carte grise (renouvellement)", "de": "Fahrzeugschein-Gebühr",
        "it": "Rinnovo immatricolazione veicolo", "pt": "Renovação do documento do veículo", "ar": "تجديد تسجيل المركبة",
    },
    "Predial (impuesto predial)": {
        "en": "Property tax (predial)", "fr": "Impôt foncier (predial)", "de": "Grundsteuer (Predial)",
        "it": "Imposta prediale", "pt": "Imposto predial", "ar": "الضريبة العقارية (بريدال)",
    },

    # ── Colombia ────────────────────────────────────────────────────────────
    "Cédula de ciudadanía": {
        "en": "Citizenship ID card", "fr": "Carte d'identité de citoyen", "de": "Personalausweis",
        "it": "Carta d'identità di cittadino", "pt": "Cartão de cidadão", "ar": "بطاقة الهوية الوطنية",
    },
    "Registro civil de nacimiento": {
        "en": "Civil registry birth record", "fr": "Registre civil de naissance", "de": "Geburtsurkunde (Standesamt)",
        "it": "Registro civile di nascita", "pt": "Registo civil de nascimento", "ar": "سجل الميلاد المدني",
    },
    "Revisión técnica mecánica (RTM)": {
        "en": "Mechanical inspection (RTM)", "fr": "Révision technique mécanique (RTM)",
        "de": "Mechanische Fahrzeugprüfung (RTM)", "it": "Revisione tecnica meccanica (RTM)",
        "pt": "Revisão técnica mecânica (RTM)", "ar": "الفحص الفني الميكانيكي (RTM)",
    },
    "Licencia de tránsito (matrícula)": {
        "en": "Vehicle registration (licencia de tránsito)", "fr": "Carte d'immatriculation (plaque)",
        "de": "Fahrzeugschein (Kennzeichen)", "it": "Licenza di circolazione (targa)",
        "pt": "Licença de trânsito (matrícula)", "ar": "رخصة المركبة (اللوحة)",
    },
    "Declaración de renta y patrimonio": {
        "en": "Income tax and asset return", "fr": "Déclaration de revenus et de patrimoine",
        "de": "Einkommensteuer- und Vermögenserklärung", "it": "Dichiarazione dei redditi e del patrimonio",
        "pt": "Declaração de renda e patrimônio", "ar": "إقرار الدخل والممتلكات",
    },
    "RUT (Registro Único Tributario)": {
        "en": "RUT (unique tax register)", "fr": "RUT (registre unique des contribuables)",
        "de": "RUT (einheitliches Steuerregister)", "it": "RUT (registro unico dei contribuenti)",
        "pt": "RUC (registo único de contribuintes)", "ar": "RUT (السجل الضريبي الموحد)",
    },
    "SOAT (seguro obligatorio de accidentes de tránsito)": {
        "en": "SOAT (mandatory traffic accident insurance)",
        "fr": "SOAT (assurance obligatoire des accidents de la circulation)",
        "de": "SOAT (Pflicht-Unfallversicherung)",
        "it": "SOAT (assicurazione obbligatoria per gli incidenti stradali)",
        "pt": "SOAT (seguro obrigatório de acidentes de trânsito)", "ar": "SOAT (التأمين الإلزامي لحوادث المرور)",
    },
    "Pico y placa": {
        "en": "Odd-even driving restriction", "fr": "Alternance de circulation", "de": "Fahrerlaubnis nach Wochentag",
        "it": "Divieto di circolazione alternato", "pt": "Rodízio de veículos", "ar": "نظام تناوب المركبات",
    },

    # ── Argentina ───────────────────────────────────────────────────────────
    "DNI (Documento Nacional de Identidad)": {
        "en": "DNI (National Identity Card)", "fr": "DNI (carte nationale d'identité)",
        "de": "Personalausweis (DNI)", "it": "DNI (documento d'identità nazionale)",
        "pt": "DNI (documento nacional de identidade)", "ar": "بطاقة الهوية الوطنية (DNI)",
    },
    "Partida de nacimiento": {
        "en": "Birth certificate", "fr": "Acte de naissance", "de": "Geburtsurkunde",
        "it": "Atto di nascita", "pt": "Certidão de nascimento", "ar": "شهادة الميلاد",
    },
    "Obra social o prepaga": {
        "en": "Social health plan or prepaid plan", "fr": "Couverture sociale ou prépayée",
        "de": "Sozialkasse oder Vorauszahlung", "it": "Obra sociale o assicurazione prepagata",
        "pt": "Obra social ou plano pré-pago", "ar": "أوبرا سوشال أو اشتراك مُسبق الدفع",
    },
    "VTV (verificación técnica vehicular)": {
        "en": "VTV (vehicle technical inspection)", "fr": "VTV (vérification technique véhicule)",
        "de": "VTV (Fahrzeugprüfung)", "it": "VTV (verifica tecnica veicoli)",
        "pt": "VTV (verificação técnica veicular)", "ar": "الفحص الفني للمركبات (VTV)",
    },
    "Cédula del automotor": {
        "en": "Vehicle ownership certificate", "fr": "Carte grise du véhicule", "de": "Fahrzeugschein",
        "it": "Carta di circolazione", "pt": "Documento do veículo", "ar": "بطاقة المركبة",
    },
    "Cuotas del consorcio": {
        "en": "Condominium fees", "fr": "Charges du syndic", "de": "Hausgeld", "it": "Spese condominiali",
        "pt": "Taxas de condomínio", "ar": "رسوم اتحاد الملاك",
    },
    "Declaración jurada de Ganancias y Bienes": {
        "en": "Sworn income and assets return", "fr": "Déclaration jurée de gains et de biens",
        "de": "Erklärung über Einkommen und Vermögen", "it": "Dichiarazione dei redditi e dei beni",
        "pt": "Declaração jurada de rendimentos e bens", "ar": "الإقرار المُصرَّح للدخل والممتلكات",
    },
    "CUIL (Clave Única de Identificación Laboral)": {
        "en": "CUIL (unique labour identification code)", "fr": "CUIL (clé unique d'identification du travail)",
        "de": "CUIL (eindeutige Arbeitsidentifikation)", "it": "CUIL (codice univoco di identificazione lavorativa)",
        "pt": "CUIL (código único de identificação laboral)", "ar": "CUIL (رمز تعريف العمل الموحد)",
    },
    "Monotributo": {
        "en": "Monotax (monotributo)", "fr": "Monotribut (micro-entrepreneur)",
        "de": "Monotribut (Pauschalbesteuerung)", "it": "Monotributo (regime forfettario)",
        "pt": "Monotributo", "ar": "نظام المبسّط للضرائب",
    },

    # ── Chile ───────────────────────────────────────────────────────────────
    "RUT / Cédula de identidad": {
        "en": "RUT / National ID card", "fr": "RUT / carte nationale d'identité",
        "de": "RUT / Personalausweis", "it": "RUT / carta d'identità",
        "pt": "RUT / cartão de identidade", "ar": "RUT / بطاقة الهوية",
    },
    "Certificado de nacimiento": {
        "en": "Birth certificate", "fr": "Certificat de naissance", "de": "Geburtsurkunde",
        "it": "Certificato di nascita", "pt": "Certidão de nascimento", "ar": "شهادة الميلاد",
    },
    "FONASA o plan de salud (Isapre)": {
        "en": "FONASA or private health plan (Isapre)", "fr": "FONASA ou mutuelle (Isapre)",
        "de": "FONASA oder Krankenversicherung (Isapre)", "it": "FONASA o piano sanitario (Isapre)",
        "pt": "FONASA ou plano de saúde (Isapre)", "ar": "فوناسا أو خطة صحية (Isapre)",
    },
    "Revisión técnica de vehículos": {
        "en": "Vehicle technical inspection", "fr": "Révision technique des véhicules",
        "de": "Technische Fahrzeugprüfung", "it": "Revisione tecnica dei veicoli",
        "pt": "Inspeção técnica de veículos", "ar": "الفحص الفني للمركبات",
    },
    "Padrón de vehículos (patente)": {
        "en": "Vehicle registry (licence plate)", "fr": "Registre des véhicules (plaque d'immatriculation)",
        "de": "Fahrzeugregister (Kennzeichen)", "it": "Anagrafe veicoli (targa)",
        "pt": "Registo de veículos (matrícula)", "ar": "سجل المركبات (اللوحة)",
    },
    "Declaración anual de renta": {
        "en": "Annual income tax return", "fr": "Déclaration annuelle de revenus",
        "de": "Jährliche Einkommensteuererklärung", "it": "Dichiarazione annuale dei redditi",
        "pt": "Declaração anual de imposto de renda", "ar": "الإقرار الضريبي السنوي",
    },
    "Aportes previsionales de independientes": {
        "en": "Self-employed pension contributions", "fr": "Cotisations retraite des indépendants",
        "de": "Rentenbeiträge für Selbstständige", "it": "Contributi previdenziali degli indipendenti",
        "pt": "Aportes previdenciários de independentes", "ar": "اشتراكات التقاعد للعاملين المستقلين",
    },
    "Cotización de AFP y seguro de cesantía": {
        "en": "AFP contribution and unemployment insurance", "fr": "Cotisation AFP et assurance chômage",
        "de": "AFP-Beitrag und Arbeitslosenversicherung",
        "it": "Contributo AFP e assicurazione contro la disoccupazione",
        "pt": "Contribuição da AFP e seguro de desemprego", "ar": "مساهمة صناديق التقاعد والتأمين ضد البطالة",
    },

    # ── Perú ────────────────────────────────────────────────────────────────
    "SIS / EsSalud": {
        "en": "SIS / EsSalud health insurance", "fr": "SIS / EsSalud (assurance maladie)",
        "de": "SIS / EsSalud (Krankenversicherung)", "it": "SIS / EsSalud (assicurazione sanitaria)",
        "pt": "SIS / EsSalud (seguro de saúde)", "ar": "SIS / EsSalud (التأمين الصحي)",
    },
    "Revisión técnica vehicular": {
        "en": "Vehicle technical inspection", "fr": "Révision technique du véhicule",
        "de": "Technische Fahrzeugprüfung", "it": "Revisione tecnica del veicolo",
        "pt": "Inspeção técnica do veículo", "ar": "الفحص الفني للمركبة",
    },
    "Tarjeta de propiedad del vehículo": {
        "en": "Vehicle title (ownership card)", "fr": "Carte grise du véhicule",
        "de": "Fahrzeugschein (Eigentumsnachweis)", "it": "Carta di proprietà del veicolo",
        "pt": "Documento de propriedade do veículo", "ar": "بطاقة ملكية المركبة",
    },
    "Declaración jurada del impuesto a la renta": {
        "en": "Sworn income tax return", "fr": "Déclaration jurée de l'impôt sur le revenu",
        "de": "Einkommensteuererklärung (eidesstattlich)", "it": "Dichiarazione giurata dell'imposta sul reddito",
        "pt": "Declaração jurada do imposto de renda", "ar": "الإقرار الضريبي المُصرَّح به",
    },
    "RUC (Registro Único de Contribuyentes)": {
        "en": "RUC (unique taxpayer registry)", "fr": "RUC (registre unique des contribuables)",
        "de": "RUC (einheitliches Steuerregister)", "it": "RUC (registro unico dei contribuenti)",
        "pt": "RUC (registo único de contribuintes)", "ar": "RUC (سجل دافعي الضرائب الموحد)",
    },

    # ── Ecuador ─────────────────────────────────────────────────────────────
    "Cédula de identidad": {
        "en": "Identity card", "fr": "Carte d'identité", "de": "Personalausweis",
        "it": "Carta d'identità", "pt": "Cartão de identidade", "ar": "بطاقة الهوية",
    },
    "IESS / Seguro Social Campesino": {
        "en": "IESS / Campesino social insurance", "fr": "IESS / assurance sociale paysanne",
        "de": "IESS / Sozialversicherung für Landarbeiter", "it": "IESS / assicurazione sociale rurale",
        "pt": "IESS / Seguro Social Campesino", "ar": "IESS / التأمين الاجتماعي الريفي",
    },
    "Revisión vehicular (VTV)": {
        "en": "Vehicle inspection (VTV)", "fr": "Contrôle du véhicule (VTV)", "de": "Fahrzeugprüfung (VTV)",
        "it": "Revisione del veicolo (VTV)", "pt": "Inspeção do veículo (VTV)", "ar": "فحص المركبة (VTV)",
    },
    "Declaración del impuesto a la renta": {
        "en": "Income tax return", "fr": "Déclaration de l'impôt sur le revenu",
        "de": "Einkommensteuererklärung", "it": "Dichiarazione dell'imposta sul reddito",
        "pt": "Declaração do imposto de renda", "ar": "إقرار ضريبة الدخل",
    },

    # ── Reino Unido ──────────────────────────────────────────────────────────
    "Número de cotización (National Insurance number)": {
        "en": "National Insurance number", "fr": "Numéro de sécurité sociale (National Insurance)",
        "de": "Nationalversicherungsnummer", "it": "Codice di previdenza sociale (National Insurance)",
        "pt": "Número de Segurança Social (National Insurance)", "ar": "رقم التأمين الوطني",
    },
    "Carnet de conducir (driving licence)": {
        "en": "Driving licence", "fr": "Permis de conduire", "de": "Führerschein",
        "it": "Patente di guida", "pt": "Carta de condução", "ar": "رخصة القيادة",
    },
    "Tarjeta del médico de cabecera (NHS)": {
        "en": "GP registration (NHS)", "fr": "Carte Vitale (NHS)", "de": "Anmeldung beim Hausarzt (NHS)",
        "it": "Iscrizione al medico di base (NHS)", "pt": "Inscrição no médico de família (NHS)",
        "ar": "بطاقة طبيب العائلة (NHS)",
    },
    "Visa o permiso de residencia (right to rent)": {
        "en": "Visa or residence permit (right to rent)", "fr": "Visa ou titre de séjour (right to rent)",
        "de": "Visum oder Aufenthaltserlaubnis", "it": "Visto o permesso di soggiorno",
        "pt": "Visto ou autorização de residência", "ar": "تأشيرة أو تصريح إقامة",
    },
    "Inspección del vehículo (MOT)": {
        "en": "Vehicle inspection (MOT)", "fr": "Contrôle technique (MOT)", "de": "Fahrzeugprüfung (MOT)",
        "it": "Revisione del veicolo (MOT)", "pt": "Inspeção do veículo (MOT)", "ar": "فحص المركبة (MOT)",
    },
    "Documento de matriculación (V5C)": {
        "en": "Vehicle logbook (V5C)", "fr": "Carte grise (V5C)", "de": "Fahrzeugschein (V5C)",
        "it": "Libretto di circolazione (V5C)", "pt": "Documento do veículo (V5C)", "ar": "بطاقة تسجيل المركبة (V5C)",
    },
    "Seguro del edificio y del contenido": {
        "en": "Buildings and contents insurance", "fr": "Assurance du logement et des biens",
        "de": "Gebäude- und Hausratversicherung", "it": "Assicurazione edificio e contenuto",
        "pt": "Seguro do edifício e do conteúdo", "ar": "تأمين المبنى والمحتويات",
    },
    "Contrato de arrendamiento (tenancy agreement)": {
        "en": "Tenancy agreement", "fr": "Contrat de location", "de": "Mietvertrag", "it": "Contratto d'affitto",
        "pt": "Contrato de arrendamento", "ar": "عقد الإيجار",
    },
    "Certificado de rendimiento energético (EPC)": {
        "en": "Energy Performance Certificate (EPC)", "fr": "Diagnostic de performance énergétique (EPC)",
        "de": "Energieausweis", "it": "Attestato di prestazione energetica",
        "pt": "Certificado de desempenho energético", "ar": "شهادة كفاءة الطاقة",
    },
    "Cuotas de la comunidad (service charges)": {
        "en": "Service charges", "fr": "Charges de copropriété", "de": "Hausgeld", "it": "Spese condominiali",
        "pt": "Quotas de condomínio", "ar": "رسوم الصيانة المشتركة",
    },
    "Council tax (impuesto municipal)": {
        "en": "Council tax", "fr": "Council tax (taxe municipale)", "de": "Gemeindesteuer (Council Tax)",
        "it": "Tassa comunale (Council Tax)", "pt": "Council tax (imposto municipal)", "ar": "ضريبة البلدية",
    },
    "Declaración del impuesto sobre la renta (Self Assessment)": {
        "en": "Self Assessment tax return", "fr": "Déclaration de revenus (auto-évaluation)",
        "de": "Steuererklärung (Selbstveranlagung)", "it": "Dichiarazione dei redditi (autodichiarazione)",
        "pt": "Declaração de IRS (autodeclaração)", "ar": "الإقرار الذاتي للضريبة",
    },
    "Cotizaciones de autónomo (National Insurance)": {
        "en": "Self-employed National Insurance", "fr": "Cotisations sociales d'indépendant (National Insurance)",
        "de": "Sozialversicherung für Selbstständige", "it": "Contributi previdenziali degli indipendenti",
        "pt": "Cotizações de trabalhador independente (National Insurance)", "ar": "اشتراكات العمل الحر",
    },
    "Pensión de jubilación del Estado y del empleador": {
        "en": "State and workplace pension", "fr": "Retraite de l'État et de l'employeur",
        "de": "Staats- und Betriebsrente", "it": "Pensione statale e aziendale",
        "pt": "Pensão do Estado e do empregador", "ar": "معاش الدولة وصاحب العمل",
    },
    "Permiso de trabajo (Skilled Worker)": {
        "en": "Work visa (Skilled Worker)", "fr": "Permis de travail (Skilled Worker)",
        "de": "Arbeitserlaubnis (Skilled Worker)", "it": "Permesso di lavoro (Skilled Worker)",
        "pt": "Visto de trabalho (Skilled Worker)", "ar": "تأشيرة عمل (Skilled Worker)",
    },

    # ── Estados Unidos ──────────────────────────────────────────────────────
    "Identificación del estado o pasaporte": {
        "en": "State ID or passport", "fr": "Carte d'identité de l'État ou passeport",
        "de": "Staatsausweis oder Reisepass", "it": "Documento d'identità statale o passaporto",
        "pt": "Documento de identidade estadual ou passaporte", "ar": "هوية الولاية أو جواز السفر",
    },
    "Licencia de conducir del estado": {
        "en": "State driver's license", "fr": "Permis de conduire de l'État", "de": "Führerschein des Bundesstaates",
        "it": "Patente di guida statale", "pt": "Carta de condução estadual", "ar": "رخصة قيادة الولاية",
    },
    "Tarjeta de seguro médico": {
        "en": "Health insurance card", "fr": "Carte d'assurance maladie", "de": "Krankenkassenkarte",
        "it": "Tessera assicurativa sanitaria", "pt": "Cartão do seguro de saúde", "ar": "بطاقة التأمين الصحي",
    },
    "Green card o visa": {
        "en": "Green card or visa", "fr": "Carte verte ou visa", "de": "Green Card oder Visum",
        "it": "Green card o visto", "pt": "Green card ou visto", "ar": "البطاقة الخضراء أو التأشيرة",
    },
    "Certificado de firma digital": {
        "en": "Digital signature certificate", "fr": "Certificat de signature numérique",
        "de": "Digitales Signaturzertifikat", "it": "Certificato di firma digitale",
        "pt": "Certificado de assinatura digital", "ar": "شهادة التوقيع الرقمي",
    },
    "Licencia profesional estatal": {
        "en": "State professional license", "fr": "Licence professionnelle de l'État",
        "de": "Berufserlaubnis des Bundesstaates", "it": "Licenza professionale statale",
        "pt": "Licença profissional estadual", "ar": "رخصة مهنية من الولاية",
    },
    "Inspección vehicular y prueba de emisiones": {
        "en": "Vehicle inspection and emissions test", "fr": "Inspection du véhicule et test d'émissions",
        "de": "Fahrzeugprüfung und Abgastest", "it": "Revisione del veicolo e test di emissioni",
        "pt": "Inspeção do veículo e teste de emissões", "ar": "فحص المركبة واختبار الانبعاثات",
    },
    "Matrícula del vehículo": {
        "en": "Vehicle registration", "fr": "Carte grise", "de": "Fahrzeugzulassung",
        "it": "Immatricolazione del veicolo", "pt": "Registo do veículo", "ar": "تسجيل المركبة",
    },
    "Licencia de conducir de otro estado": {
        "en": "Out-of-state driving license", "fr": "Permis de conduire d'un autre État",
        "de": "Führerschein eines anderen Bundesstaates", "it": "Patente di guida di un altro stato",
        "pt": "Carta de condução de outro estado", "ar": "رخصة قيادة من ولاية أخرى",
    },
    "Cuotas de la asociación de propietarios": {
        "en": "Homeowners association fees", "fr": "Charges de l'association des propriétaires",
        "de": "Hausverwaltungsgebühren", "it": "Spese dell'associazione dei proprietari",
        "pt": "Taxas da associação de proprietários", "ar": "رسوم جمعية الملاك",
    },
    "Declaración de impuestos federales y estatales": {
        "en": "Federal and state tax filing", "fr": "Déclaration des impôts fédéraux et de l'État",
        "de": "Steuererklärung (Bund und Bundesstaat)", "it": "Dichiarazione fiscale federale e statale",
        "pt": "Declaração de impostos federal e estadual", "ar": "الإقرار الضريبي الفيدرالي والولائي",
    },
    "Impuesto de trabajo por cuenta propia (IRS)": {
        "en": "Self-employment tax (IRS)", "fr": "Impôt sur les revenus des indépendants (IRS)",
        "de": "Steuer auf selbstständige Einkommen (IRS)", "it": "Imposta sul lavoro autonomo (IRS)",
        "pt": "Imposto do trabalho independente (IRS)", "ar": "ضريبة العمل الحر (IRS)",
    },
    "Plan de jubilación (401k / IRA)": {
        "en": "Retirement plan (401k / IRA)", "fr": "Plan de retraite (401k / IRA)",
        "de": "Rentenplan (401k / IRA)", "it": "Piano di pensionamento (401k / IRA)",
        "pt": "Plano de aposentadoria (401k / IRA)", "ar": "خطة التقاعد (401k / IRA)",
    },
    "Visa de trabajo": {
        "en": "Work visa", "fr": "Visa de travail", "de": "Arbeitsvisum", "it": "Visto di lavoro",
        "pt": "Visto de trabalho", "ar": "تأشيرة عمل",
    },
    "Número de la Seguridad Social": {
        "en": "Social Security number", "fr": "Numéro de sécurité sociale", "de": "Sozialversicherungsnummer",
        "it": "Codice di previdenza sociale", "pt": "Número da Segurança Social", "ar": "رقم الضمان الاجتماعي",
    },
    "Título de propiedad del vehículo": {
        "en": "Vehicle title", "fr": "Titre de propriété du véhicule", "de": "Fahrzeugbrief",
        "it": "Titolo di proprietà del veicolo", "pt": "Título de propriedade do veículo", "ar": "سند ملكية المركبة",
    },
    "Impuesto sobre la propiedad": {
        "en": "Property tax", "fr": "Impôt foncier", "de": "Grundsteuer", "it": "Imposta sulla proprietà",
        "pt": "Imposto sobre a propriedade", "ar": "ضريبة العقار",
    },

    # ── Francia ─────────────────────────────────────────────────────────────
    "Tarjeta nacional de identidad (CNI)": {
        "en": "National ID card (CNI)", "fr": "Carte nationale d'identité (CNI)",
        "de": "Personalausweis (CNI)", "it": "Carta d'identità nazionale (CNI)",
        "pt": "Cartão de cidadão (CNI)", "ar": "بطاقة الهوية الوطنية (CNI)",
    },
    "Tarjeta Vitale": {
        "en": "Vitale card", "fr": "Carte Vitale", "de": "Krankenkassenkarte", "it": "Carta Vitale",
        "pt": "Cartão Vitale", "ar": "بطاقة فيتال",
    },
    "Certificado electrónico": {
        "en": "Electronic certificate", "fr": "Certificat électronique", "de": "Elektronisches Zertifikat",
        "it": "Certificato elettronico", "pt": "Certificado eletrónico", "ar": "الشهادة الإلكترونية",
    },
    "Control técnico (CT)": {
        "en": "Technical inspection (CT)", "fr": "Contrôle technique (CT)", "de": "Hauptuntersuchung (TÜV)",
        "it": "Revisione periodica (CT)", "pt": "Inspeção técnica (CT)", "ar": "الفحص الفني (CT)",
    },
    "Certificado de matriculación": {
        "en": "Vehicle registration certificate", "fr": "Certificat d'immatriculation",
        "de": "Zulassungsbescheinigung", "it": "Carta di circolazione", "pt": "Certificado de matrícula",
        "ar": "شهادة تسجيل المركبة",
    },
    "Diagnóstico energético (DPE)": {
        "en": "Energy performance diagnosis (DPE)", "fr": "Diagnostic de performance énergétique (DPE)",
        "de": "Energieausweis (DPE)", "it": "Attestato di prestazione energetica (DPE)",
        "pt": "Diagnóstico energético (DPE)", "ar": "تشخيص كفاءة الطاقة (DPE)",
    },
    "Cuotas de copropiedad": {
        "en": "Co-ownership fees", "fr": "Charges de copropriété", "de": "Eigentümergemeinschaft Gebühren",
        "it": "Spese condominiali", "pt": "Quotas de condomínio", "ar": "رسوم الملكية المشتركة",
    },
    "Declaración de impuestos (impuesto sobre la renta)": {
        "en": "Tax return (income tax)", "fr": "Déclaration de revenus (impôt sur le revenu)",
        "de": "Steuererklärung (Einkommensteuer)", "it": "Dichiarazione dei redditi (IRPF)",
        "pt": "Declaração de IRS", "ar": "الإقرار الضريبي (ضريبة الدخل)",
    },
    "Cotizaciones sociales de los autónomos": {
        "en": "Self-employed social contributions", "fr": "Cotisations sociales des indépendants",
        "de": "Sozialversicherungsbeiträge für Selbstständige",
        "it": "Contributi previdenziali degli indipendenti",
        "pt": "Cotizações sociais de trabalhadores independentes", "ar": "اشتراكات العمل الحر الاجتماعية",
    },
    "Transporte urbano (Navigo)": {
        "en": "Public transport pass (Navigo)", "fr": "Titre de transport urbain (Navigo)",
        "de": "ÖPNV-Karte (Navigo)", "it": "Abbonamento trasporto urbano (Navigo)",
        "pt": "Passe de transporte urbano (Navigo)", "ar": "بطاقة النقل الحضري (Navigo)",
    },
    "Permiso de trabajo (Passeport Talent)": {
        "en": "Work permit (Passeport Talent)", "fr": "Permis de travail (Passeport Talent)",
        "de": "Arbeitserlaubnis (Passeport Talent)", "it": "Permesso di lavoro (Passeport Talent)",
        "pt": "Autorização de residência para trabalho (Passeport Talent)", "ar": "تصريح العمل (Passeport Talent)",
    },
    "Distintivo Crit'Air (zonas de bajas emisiones)": {
        "en": "Crit'Air sticker (low-emission zones)", "fr": "Vignette Crit'Air (zones à faibles émissions)",
        "de": "Crit'Air-Plakette (Umweltzonen)", "it": "Distintivo Crit'Air (aree a basse emissioni)",
        "pt": "Distintivo Crit'Air (zonas de baixas emissões)", "ar": "ملصق Crit'Air (مناطق الانبعاثات المنخفضة)",
    },

    # ── Alemania ────────────────────────────────────────────────────────────
    "Documento de identidad (Personalausweis)": {
        "en": "ID document (Personalausweis)", "fr": "Carte d'identité (Personalausweis)",
        "de": "Personalausweis", "it": "Documento d'identità (Personalausweis)",
        "pt": "Documento de identificação (Personalausweis)", "ar": "وثيقة الهوية (Personalausweis)",
    },
    "Carnet de conducir (Führerschein)": {
        "en": "Driving license (Führerschein)", "fr": "Permis de conduire (Führerschein)",
        "de": "Führerschein", "it": "Patente di guida (Führerschein)",
        "pt": "Carta de condução (Führerschein)", "ar": "رخصة القيادة (Führerschein)",
    },
    "Tarjeta sanitaria (Gesundheitskarte)": {
        "en": "Health insurance card (Gesundheitskarte)", "fr": "Carte de santé (Gesundheitskarte)",
        "de": "Gesundheitskarte", "it": "Tessera sanitaria (Gesundheitskarte)",
        "pt": "Cartão de saúde (Gesundheitskarte)", "ar": "بطاقة الصحة (Gesundheitskarte)",
    },
    "Inspección vehicular (TÜV)": {
        "en": "Vehicle inspection (TÜV)", "fr": "Contrôle technique (TÜV)", "de": "Hauptuntersuchung (TÜV)",
        "it": "Revisione del veicolo (TÜV)", "pt": "Inspeção do veículo (TÜV)", "ar": "فحص المركبة (TÜV)",
    },
    "Certificado de matriculación (Zulassungsbescheinigung)": {
        "en": "Vehicle registration certificate (Zulassungsbescheinigung)",
        "fr": "Certificat d'immatriculation (Zulassungsbescheinigung)", "de": "Zulassungsbescheinigung",
        "it": "Carta di circolazione (Zulassungsbescheinigung)",
        "pt": "Documento do veículo (Zulassungsbescheinigung)", "ar": "شهادة تسجيل المركبة (Zulassungsbescheinigung)",
    },
    "Revisión de calderas y de agua": {
        "en": "Boiler and hot water check", "fr": "Entretien chaudière et eau chaude",
        "de": "Kessel- und Warmwasserprüfung", "it": "Verifica caldaia e acqua calda",
        "pt": "Verificação de caldeira e água quente", "ar": "فحص الغلاية والماء الساخن",
    },
    "Certificado energético (Energieausweis)": {
        "en": "Energy certificate (Energieausweis)", "fr": "Certificat énergétique (Energieausweis)",
        "de": "Energieausweis", "it": "Attestato energetico (Energieausweis)",
        "pt": "Certificado energético (Energieausweis)", "ar": "شهادة الطاقة (Energieausweis)",
    },
    "Cuotas de la comunidad de propietarios": {
        "en": "Homeowners association fees", "fr": "Charges de copropriété", "de": "Hausgeld",
        "it": "Spese condominiali", "pt": "Quotas de condomínio", "ar": "رسوم جمعية الملاك",
    },
    "Declaración del impuesto sobre la renta": {
        "en": "Income tax return", "fr": "Déclaration de revenus", "de": "Einkommensteuererklärung",
        "it": "Dichiarazione dei redditi", "pt": "Declaração de imposto de renda", "ar": "إقرار ضريبة الدخل",
    },
    "Cotizaciones de autónomo (seguros sociales)": {
        "en": "Self-employed social insurance", "fr": "Cotisations sociales d'indépendant",
        "de": "Beiträge zur Kranken- und Rentenversicherung", "it": "Contributi previdenziali degli indipendenti",
        "pt": "Cotizações de trabalhador independente", "ar": "اشتراكات التأمين الاجتماعي",
    },
    "Plan de pensiones (renta legal)": {
        "en": "Pension plan (statutory pension)", "fr": "Plan de retraite (régime obligatoire)",
        "de": "Rentenplan (gesetzliche Rente)", "it": "Piano pensionistico (previdenza obbligatoria)",
        "pt": "Plano de reformas (pensão legal)", "ar": "خطة التقاعد (المعاش القانوني)",
    },
    "Cámara profesional (Berufskammer)": {
        "en": "Professional chamber (Berufskammer)", "fr": "Ordre professionnel (Kammer)",
        "de": "Berufskammer", "it": "Ordine professionale (albo)", "pt": "Ordem profissional",
        "ar": "الغرفة المهنية (Berufskammer)",
    },

    # ── Italia ──────────────────────────────────────────────────────────────
    "Carta de identidad electrónica (CIE)": {
        "en": "Electronic ID card (CIE)", "fr": "Carte d'identité électronique (CIE)",
        "de": "Elektronischer Personalausweis (CIE)", "it": "Carta d'identità elettronica (CIE)",
        "pt": "Cartão de identidade eletrónico (CIE)", "ar": "بطاقة الهوية الإلكترونية (CIE)",
    },
    "Tessera sanitaria": {
        "en": "Health card", "fr": "Carte de santé", "de": "Krankenkassenkarte", "it": "Tessera sanitaria",
        "pt": "Cartão de saúde", "ar": "بطاقة الصحة",
    },
    "Revisión del vehículo (revisione periodica)": {
        "en": "Vehicle inspection (revisione periodica)", "fr": "Contrôle technique (revision)",
        "de": "Fahrzeugprüfung (Revision)", "it": "Revisione periodica del veicolo",
        "pt": "Inspeção periódica do veículo", "ar": "المراجعة الدورية للمركبة",
    },
    "Libretto del vehículo": {
        "en": "Vehicle registration document", "fr": "Carte grise du véhicule", "de": "Fahrzeugschein",
        "it": "Libretto di circolazione", "pt": "Documento do veículo", "ar": "بطاقة المركبة",
    },
    "Cuotas del condominio": {
        "en": "Condominium fees", "fr": "Charges de copropriété", "de": "Hausgeld", "it": "Spese condominiali",
        "pt": "Taxas de condomínio", "ar": "رسوم المبنى السكني",
    },
    "Certificado energético (APE)": {
        "en": "Energy certificate (APE)", "fr": "Certificat énergétique (APE)", "de": "Energieausweis (APE)",
        "it": "Attestato di prestazione energetica (APE)", "pt": "Certificado energético (APE)",
        "ar": "شهادة الطاقة (APE)",
    },
    "Declaración de impuestos (IRPF)": {
        "en": "Tax return (IRPF)", "fr": "Déclaration de revenus (IRPF)", "de": "Steuererklärung (IRPF)",
        "it": "Dichiarazione dei redditi (IRPF)", "pt": "Declaração de IRS (IRPF)", "ar": "الإقرار الضريبي (IRPF)",
    },
    "Cotizaciones de autónomo (INPS)": {
        "en": "Self-employed contributions (INPS)", "fr": "Cotisations des indépendants (INPS)",
        "de": "Beiträge Selbstständige (INPS)", "it": "Contributi degli indipendenti (INPS)",
        "pt": "Cotizações de trabalhador independente (INPS)", "ar": "اشتراكات العمل الحر (INPS)",
    },
    "Plan de pensiones (INPS)": {
        "en": "Pension plan (INPS)", "fr": "Plan de retraite (INPS)", "de": "Rentenplan (INPS)",
        "it": "Piano pensionistico (INPS)", "pt": "Fundo de reformas (INPS)", "ar": "خطة التقاعد (INPS)",
    },
    "Orden profesional (albo)": {
        "en": "Professional register (albo)", "fr": "Ordre professionnel (albo)", "de": "Berufsregister (albo)",
        "it": "Albo professionale", "pt": "Ordem profissional (albo)", "ar": "السجل المهني (albo)",
    },
    "Permiso de trabajo (permesso di soggiorno)": {
        "en": "Work permit (permesso di soggiorno)", "fr": "Permis de travail (permesso di soggiorno)",
        "de": "Arbeitserlaubnis (permesso di soggiorno)", "it": "Permesso di soggiorno per lavoro",
        "pt": "Autorização de residência para trabalho", "ar": "تصريح الإقامة للعمل",
    },

    # ── Portugal ────────────────────────────────────────────────────────────
    "Cartão de cidadão": {
        "en": "Citizen card", "fr": "Carte de citoyen", "de": "Personalausweis", "it": "Carta d'identità",
        "pt": "Cartão de cidadão", "ar": "بطاقة المواطن",
    },
    "Certidão de nascimento": {
        "en": "Birth certificate", "fr": "Certificat de naissance", "de": "Geburtsurkunde",
        "it": "Certificato di nascita", "pt": "Certidão de nascimento", "ar": "شهادة الميلاد",
    },
    "Carta de condução": {
        "en": "Driving licence", "fr": "Permis de conduire", "de": "Führerschein", "it": "Patente di guida",
        "pt": "Carta de condução", "ar": "رخصة القيادة",
    },
    "Cartão de saúde (SNS)": {
        "en": "Health card (SNS)", "fr": "Carte de santé (SNS)", "de": "Krankenkassenkarte (SNS)",
        "it": "Tessera sanitaria (SNS)", "pt": "Cartão de saúde (SNS)", "ar": "بطاقة الصحة (SNS)",
    },
    "Certificado digital (Gov.pt)": {
        "en": "Digital certificate (Gov.pt)", "fr": "Certificat numérique (Gov.pt)",
        "de": "Digitales Zertifikat (Gov.pt)", "it": "Certificato digitale (Gov.pt)",
        "pt": "Certificado digital (Gov.pt)", "ar": "الشهادة الرقمية (Gov.pt)",
    },
    "Inspeção periódica obrigatória (IPO)": {
        "en": "Mandatory periodic inspection (IPO)", "fr": "Contrôle technique obligatoire (IPO)",
        "de": "Pflicht-Fahrzeugprüfung (IPO)", "it": "Revisione periodica obbligatoria (IPO)",
        "pt": "Inspeção periódica obrigatória (IPO)", "ar": "الفحص الدوري الإلزامي (IPO)",
    },
    "Documento único do veículo (DUC)": {
        "en": "Vehicle document (DUC)", "fr": "Carte grise du véhicule (DUC)", "de": "Fahrzeugschein (DUC)",
        "it": "Documento unico del veicolo (DUC)", "pt": "Documento único do veículo (DUC)", "ar": "بطاقة المركبة (DUC)",
    },
    "Quotas de condomínio": {
        "en": "Condominium fees", "fr": "Charges de copropriété", "de": "Hausgeld", "it": "Spese condominiali",
        "pt": "Quotas de condomínio", "ar": "رسوم المبنى السكني",
    },
    "Declaração de IRS": {
        "en": "Income tax return (IRS)", "fr": "Déclaration de revenus (IRS)", "de": "Einkommensteuererklärung (IRS)",
        "it": "Dichiarazione dei redditi (IRS)", "pt": "Declaração de IRS", "ar": "إقرار ضريبة الدخل",
    },
    "Cotizações de trabalhador independente": {
        "en": "Self-employed contributions", "fr": "Cotisations d'indépendant", "de": "Beiträge Selbstständige",
        "it": "Contributi da autonomo", "pt": "Cotizações de trabalhador independente", "ar": "اشتراكات العامل المستقل",
    },
    "Fundo de pensions": {
        "en": "Pension fund", "fr": "Fonds de pension", "de": "Rentenfonds", "it": "Fondo pensionistico",
        "pt": "Fundo de reformas", "ar": "صندوق التقاعد",
    },
    "IMI (imposto municipal sobre o imóvel)": {
        "en": "IMI (municipal property tax)", "fr": "IMI (taxe municipale immobilière)",
        "de": "IMI (Gemeindesteuer auf Immobilien)", "it": "IMI (imposta municipale sugli immobili)",
        "pt": "IMI (imposto municipal sobre o imóvel)", "ar": "IMI (الضريبة البلدية على العقار)",
    },
}


def collation_weight(char: str):
    """Aproximación a la colación de Xcode (espacios < puntuación < símbolos < dígitos < letras)."""
    category = unicodedata.category(char)
    if category in ("Zs", "Zl", "Zp", "Cc"):
        return (0, ord(char))
    if category.startswith("P"):
        return (1, ord(char))
    if category == "Sc":
        return (2, ord(char))
    if category in ("Sm", "Sk", "So"):
        return (3, ord(char))
    if category == "Nd":
        return (4, ord(char))
    if category.startswith("L"):
        return (5, ord(char))
    if category.startswith("M"):
        return (6, ord(char))
    return (7, ord(char))


def sort_key(text: str):
    return [collation_weight(char) for char in text]


def insert_sorted(strings: dict, key: str) -> None:
    """Inserta una clave nueva sin reordenar las existentes (diff limpio)."""
    if key in strings:
        return
    new_weight = sort_key(key)
    rebuilt = {}
    inserted = False
    for existing, value in strings.items():
        if not inserted and sort_key(existing) > new_weight:
            rebuilt[key] = {}
            inserted = True
        rebuilt[existing] = value
    if not inserted:
        rebuilt[key] = {}
    strings.clear()
    strings.update(rebuilt)


def dump_xcstrings(data: dict, raw: str) -> str:
    """Vuelve a escribir el archivo conservando su formato original."""
    separator = " : " if '"sourceLanguage" : ' in raw else ": "
    text = json.dumps(data, indent=2, separators=(",", separator), sort_keys=False, ensure_ascii=False)
    if '"" : {\n\n    }' in raw:
        text = text.replace('"" : {}', '"" : {\n\n    }', 1)
    return text


def main() -> None:
    for path in FILES:
        raw = path.read_text(encoding="utf-8")
        data = json.loads(raw)
        strings = data.setdefault("strings", {})

        for key, translations in T.items():
            insert_sorted(strings, key)
            localizations = strings[key].setdefault("localizations", {})
            for lang in LANGS:
                localizations[lang] = {
                    "stringUnit": {"state": "translated", "value": translations[lang]}
                }

        path.write_text(dump_xcstrings(data, raw), encoding="utf-8")
        print(f"{path.name}: {len(T)} claves en {len(LANGS)} idiomas")


if __name__ == "__main__":
    main()
