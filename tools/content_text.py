"""Readability of generated human text; IDs, enums and legacy definitions stay intact."""
import re

TEXT_KEYS = {"title", "description", "symptoms", "label", "text", "why", "more",
             "hint", "hints", "explanations", "warning", "question"}


def readable(text):
    text = re.sub(r"(?<=\w)\(", " (", text)
    text = re.sub(r",(?=\S)", lambda m: "," if
                  m.start() > 0 and text[m.start()-1].isdigit() and
                  text[m.end()].isdigit() else ", ", text)
    text = re.sub(r"(VMID|VLAN|VHDX|IP|přiděl|Vytvoř|rezerva|služby|kapacita)(?=\d)", r"\1 ", text)
    text = re.sub(r"(?<=\d)(?=(?:vCPU|MiB|GiB|GB|TB|TiB)\b)", " ", text)
    return text.replace("aIP", "a IP").replace("=4 GiB", "= 4 GiB")


def polish(value, text=False):
    if isinstance(value, dict):
        for key, child in value.items():
            value[key] = polish(child, key in TEXT_KEYS)
    elif isinstance(value, list):
        value[:] = [polish(child, text) for child in value]
    elif text and isinstance(value, str):
        return readable(value)
    return value
