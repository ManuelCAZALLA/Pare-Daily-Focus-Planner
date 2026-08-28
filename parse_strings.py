import json

try:
    with open("Recuerda tus Trámites/Resources/Localizable.xcstrings", "r") as f:
        data = json.load(f)
        
    strings = data.get("strings", {})
    missing_en = []
    
    for key, value in strings.items():
        localizations = value.get("localizations", {})
        en = localizations.get("en")
        if not en or en.get("stringUnit", {}).get("state") != "translated":
            missing_en.append(key)
            
    print(json.dumps(missing_en, ensure_ascii=False, indent=2))
except Exception as e:
    print(f"Error: {e}")
