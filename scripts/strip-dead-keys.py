#!/usr/bin/env python3
"""One-off cleanup: drop localization keys and L10n accessors that belonged to
the shortcuts/features removed from the Settings shortcut pane."""
import glob
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DEAD = [
    # 12. quick pin
    "quickPinShortcutHeader", "quickPinShortcutDefaultDisplay",
    "quickPinShortcutClear", "shortcutConflictQuickPin", "dragToQuickPin",
    # 13. pin selected image
    "selectedImagePinShortcutHeader", "selectedImagePinShortcutDefaultDisplay",
    "selectedImagePinShortcutClear", "selectedImagePinNoImage",
    "shortcutConflictSelectedImagePin", "pinFromFinderHint",
    # 14. pin current/clipboard image
    "clipboardImagePinShortcutHeader", "clipboardImagePinShortcutDefaultDisplay",
    "clipboardImagePinShortcutClear", "clipboardImagePinNoImage",
    "shortcutConflictClipboardImagePin", "pinFromClipboardHint",
    # 20. pin clipboard text
    "clipboardTextPinShortcutHeader", "clipboardTextPinShortcutDefaultDisplay",
    "clipboardTextPinShortcutClear", "clipboardTextPinNoText",
    "shortcutConflictClipboardTextPin", "pinFromClipboardTextHint",
    # 9. edit selected image
    "selectedImageEditShortcutHeader", "selectedImageEditShortcutHint",
    "selectedImageEditShortcutDefaultDisplay", "selectedImageEditNoImage",
    "shortcutConflictSelectedImageEdit",
    # 11. edit clipboard image
    "clipboardImageEditShortcutHeader", "clipboardImageEditShortcutHint",
    "clipboardImageEditShortcutDefaultDisplay", "clipboardImageEditNoImage",
    "shortcutConflictClipboardImageEdit",
    # 8. color picker shortcut (the eyedropper feature itself stays)
    "colorPickerShortcutHeader", "colorPickerShortcutDefaultDisplay",
    "shortcutConflictColorPicker",
    # 4/5/6. history navigation + history panel shortcuts
    "previousHistoryImageShortcutHeader", "nextHistoryImageShortcutHeader",
    "shortcutConflictPreviousHistoryImage", "shortcutConflictNextHistoryImage",
    "historyPanelShortcutHeader", "historyPanelShortcutDefaultDisplay",
    "shortcutConflictHistoryPanel",
]
DEADSET = set(DEAD)

strings_removed = 0
for path in sorted(glob.glob(os.path.join(ROOT, "Resources", "*.lproj", "Localizable.strings"))):
    with open(path, encoding="utf-8") as fh:
        lines = fh.readlines()
    kept, dropped = [], 0
    for line in lines:
        m = re.match(r'\s*"([A-Za-z0-9_]+)"\s*=', line)
        if m and m.group(1) in DEADSET:
            dropped += 1
            continue
        kept.append(line)
    if dropped:
        with open(path, "w", encoding="utf-8") as fh:
            fh.writelines(kept)
    strings_removed += dropped
    print(f"{os.path.relpath(path, ROOT)}: -{dropped}")

defaults = os.path.join(ROOT, "capcap", "Utilities", "Defaults.swift")
with open(defaults, encoding="utf-8") as fh:
    lines = fh.readlines()
kept, dropped = [], 0
for line in lines:
    m = re.match(r'\s*static var ([A-Za-z0-9_]+)\s*:\s*String\s*\{\s*s\(', line)
    if m and m.group(1) in DEADSET:
        dropped += 1
        continue
    kept.append(line)
with open(defaults, "w", encoding="utf-8") as fh:
    fh.writelines(kept)
print(f"Defaults.swift: -{dropped} accessors, strings: -{strings_removed}")
