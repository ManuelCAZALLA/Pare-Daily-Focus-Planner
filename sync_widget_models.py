#!/usr/bin/env python3
"""Sincroniza los modelos espejo del widget con los de la app.

El widget extension no puede ver el código de la app (misma razón por la que
existen las copias de LifeObligation / TramiteTask), así que este script copia
LifeAdminCategory, TramiteCountry y ObligationTemplate desde la app al widget.

Uso:  python3 sync_widget_models.py
"""

import pathlib
import re

ROOT = pathlib.Path(__file__).resolve().parent
APP = ROOT / "Recuerda tus Trámites" / "Domain" / "Enums"
WIDGET = ROOT / "TramiteWidgets" / "WidgetModels.swift"
MARKER = "// MARK: - Plantillas de trámites (para título e icono de categoría)"


def body(path: pathlib.Path) -> str:
    text = path.read_text(encoding="utf-8")
    lines = [line for line in text.splitlines() if line.strip() not in {"import Foundation"}]
    # quita el comentario de cabecera del archivo
    if lines and lines[0].startswith("//"):
        lines = lines[1:]
    return "\n".join(lines).strip() + "\n"


def main() -> None:
    block = "\n".join(
        [
            body(APP / "LifeAdminCategory.swift"),
            body(APP / "TramiteCountry.swift"),
            body(APP / "ObligationTemplate.swift"),
        ]
    )

    widget = WIDGET.read_text(encoding="utf-8")
    head, marker, _ = widget.partition(MARKER)
    if not marker:
        raise SystemExit(f"No se encontró el marcador en {WIDGET}")

    WIDGET.write_text(
        head
        + marker
        + "\n"
        + "// Generado por sync_widget_models.py — no editar a mano.\n\n"
        + block,
        encoding="utf-8",
    )
    print(f"{WIDGET} sincronizado ({len(block.splitlines())} líneas)")


if __name__ == "__main__":
    main()
