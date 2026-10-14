"""Rebuild the synchronous Dart fixture from the canonical demonstration JSON."""
import json
from pathlib import Path
root = Path(__file__).resolve().parent.parent
fixture = json.loads((root / "backend/campus_demo.json").read_text(encoding="utf-8"))
(root / "lib/core/data/demo_content.dart").write_text(
    "// Generated from backend/campus_demo.json by tooling/generate_demo_content.py.\n"
    "// Fictional demonstration data, not university records.\n"
    "const Map<String, Object?> demoContent = " + json.dumps(fixture, ensure_ascii=False, indent=2).replace('$', r'\$') + ";\n", encoding="utf-8")
