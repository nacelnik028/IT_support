# Samostatné Windows EXE

`ITSupportSimulator.exe` z 9. 11. 2026 obsahuje opravené tabule v rozcestníku
a serverovně i síťovou učebnu 05 / Počítačové sítě se 40 úlohami. Herní data
jsou vložená přímo do souboru. Jde o Windows x86_64 Debug pod 100 MiB.
Kontrolní součet je v `SHA256SUMS`.
[Ovládání a zdroje úloh](../docs/NETWORK_LAB.md).

## Sestavení

Použij Godot 4.7.2.stable.official.ed1daf0bf a shodnou oficiální Windows Debug šablonu.
Z kořene projektu:

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe'
# nebo
python tools/build_windows.py --godot C:/Godot/Godot_console.exe
```

Builder exportuje v izolované dočasné kopii, bezeztrátově komprimuje katalogy,
kontroluje PE/vložený PCK/limit velikosti a spustí přejmenované EXE z cizí složky.
Teprve úspěšný výsledek nahradí distribuci. Zdrojové katalogy zůstávají beze změn.
Přesné výsledky a rozdílné zdroje Windows/PICO viz BUILD_INFO.md a VERIFICATION.json.

## Ověření této distribuce

Prošlo všech 53 sad ze seznamu `Test-All.ps1` včetně všech tří výukových režimů.
Nativní testy spustily samotné EXE z oddělené složky s izolovaným uložením
a nastavením. Testy `network_lab.gd` a `package_content.gd` pracovaly přímo
s balíčkem vloženým v tomto EXE. Prošlo 855 kontrol laboratoře bez
grafiky, 862 s grafikou a 6724 kontrol obsahu.
Ze stejného balíčku byly pořízeny snímky obou tabulí a prošlo 116 kontrol
přístupu do programovací učebny.

PICO APK v `pico4/` je starší vydání 1.5.0 / code 6. VR rozhraní a vstupy byly
ověřeny syntetickými ovladači v Godotu. Zkouška na fyzickém PICO zbývá.
