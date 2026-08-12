#!/usr/bin/env python3
"""Completa las traducciones de las claves pro.* (y rellena es de dos claves
del módulo Obligaciones) en el catálogo de la app y resincroniza el del widget."""
import json
import shutil

APP_CATALOG = "Pare Daily Focus Planner/Resources/Localizable.xcstrings"
WIDGET_CATALOG = "PareWidgets/Resources/Localizable.xcstrings"

entries = {
    "pro.badge": {l: "PRO" for l in ["ar", "de", "en", "es", "fr", "it", "pt"]},
    "PRO": {l: "PRO" for l in ["ar", "de", "en", "es", "fr", "it", "pt"]},
    "pro.escalatedAlerts.title": {
        "es": "Alertas intensificadas",
        "en": "Escalated alerts",
        "de": "Intensivierte Warnungen",
        "fr": "Alertes renforcées",
        "it": "Avvisi intensificati",
        "pt": "Alertas reforçadas",
        "ar": "تنبيهات مشددة",
    },
    "pro.escalatedAlerts.toggle": {
        "es": "Activar alertas intensificadas",
        "en": "Enable escalated alerts",
        "de": "Intensivierte Warnungen aktivieren",
        "fr": "Activer les alertes renforcées",
        "it": "Attiva avvisi intensificati",
        "pt": "Ativar alertas reforçadas",
        "ar": "تفعيل التنبيهات المشددة",
    },
    "pro.escalatedAlerts.schedule": {
        "es": "Recibirás avisos 1 mes, 2 semanas, 1 semana y 2 días antes del vencimiento.",
        "en": "You'll be alerted 1 month, 2 weeks, 1 week, and 2 days before expiry.",
        "de": "Du wirst 1 Monat, 2 Wochen, 1 Woche und 2 Tage vor Ablauf benachrichtigt.",
        "fr": "Vous serez alerté 1 mois, 2 semaines, 1 semaine et 2 jours avant l'échéance.",
        "it": "Riceverai avvisi 1 mese, 2 settimane, 1 settimana e 2 giorni prima della scadenza.",
        "pt": "Receberás avisos 1 mês, 2 semanas, 1 semana e 2 dias antes do vencimento.",
        "ar": "ستتلقى تنبيهات قبل الاستحقاق بشهر وأسبوعين وأسبوع ويومين.",
    },
    "pro.familyProfiles.title": {
        "es": "Perfiles familiares",
        "en": "Family profiles",
        "de": "Familienprofile",
        "fr": "Profils familiaux",
        "it": "Profili familiari",
        "pt": "Perfis familiares",
        "ar": "ملفات العائلة",
    },
    "pro.locked": {
        "es": "Bloqueado",
        "en": "Locked",
        "de": "Gesperrt",
        "fr": "Verrouillé",
        "it": "Bloccato",
        "pt": "Bloqueado",
        "ar": "مقفل",
    },
    "pro.widgets.locked": {
        "es": "Los widgets requieren Pare Pro",
        "en": "Widgets require Pare Pro",
        "de": "Widgets erfordern Pare Pro",
        "fr": "Les widgets nécessitent Pare Pro",
        "it": "I widget richiedono Pare Pro",
        "pt": "Os widgets requerem Pare Pro",
        "ar": "تتطلب الأدوات Pare Pro",
    },
    "Toca para registrar": {
        "es": "Toca para registrar",
    },
    "Vence el %@": {
        "es": "Vence el %@",
    },
}


def load(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


app = load(APP_CATALOG)
strings = app.setdefault("strings", {})

for key, localizations in entries.items():
    entry = strings.setdefault(key, {"localizations": {}})
    locs = entry.setdefault("localizations", {})
    for lang, value in localizations.items():
        locs[lang] = {"stringUnit": {"state": "translated", "value": value}}

save(APP_CATALOG, app)
shutil.copyfile(APP_CATALOG, WIDGET_CATALOG)

remaining = [k for k, v in strings.items() if not v.get("localizations")]
print(f"OK. Claves vacías restantes: {remaining}")
