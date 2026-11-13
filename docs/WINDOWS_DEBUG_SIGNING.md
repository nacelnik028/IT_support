# Lokální podpis Windows Debug EXE

`build/ITSupportSimulator.exe` je podepsané vlastním testovacím certifikátem
**Training academy Local Debug** (RSA 3072, SHA256). Podpis umožňuje ověřit
neporušenost souboru. **Nejde o certifikát důvěryhodného vydavatele.** Microsoft
uvádí, že SmartScreen zachází s vlastním certifikátem stejně jako s nepodepsaným
souborem; upozornění proto může zůstat. Podpis také nevyřeší konkrétní antivirovou
detekci. [Vysvětlení Microsoftu](https://learn.microsoft.com/windows/apps/package-and-deploy/smartscreen-reputation).

Klíč je neexportovatelný a zůstává v osobním úložišti `Cert:\CurrentUser\My`
uživatele na počítači, kde sestavení vzniklo. Nevkládá se do hry ani Gitu.
Certifikát se nepřidává mezi důvěryhodné kořeny ani vydavatele; ochrany Windows
se nemění. Lokální certifikát platí tři roky, podpis nemá časové razítko.

Další sestavení se stejným klíčem vytvoříš takto:

```powershell
./tools/Build-Windows.ps1 -GodotPath 'C:/Godot/Godot_console.exe' -SignDebug
# Nebo přímo:
python tools/build_windows.py --godot C:/Godot/Godot_console.exe --sign-debug
```

Příznak je volitelný; bez něj nebo při přímém exportu z editoru podpis nevznikne.
Na jiném počítači/účtu vznikne jiný klíč. Po vypršení platnosti nebo pokud zbývá
méně než 30 dní se vytvoří nový certifikát. Skript nevyžaduje Windows SDK.

Podpis vzniká na dočasném exportu před kontrolou velikosti a skutečným spuštěním;
teprve po úspěchu se nahradí distribuční EXE. Builder ověřuje podpis CMS,
SHA256 skutečného PE a shodu celého vloženého herního packu. Výsledek a otisk
veřejného certifikátu jsou v `build/BUILD_INFO.json`.

Samostatná kontrola (podepisuje pouze dočasné kopie, nepouští hru):

```powershell
python tools/test_windows_signing.py
Get-AuthenticodeSignature -LiteralPath build/ITSupportSimulator.exe
```

Test ověřuje opětovné použití klíče, nezměněný pack, limit 100 MiB a skutečné
odmítnutí pozměněné kopie Windows (`HashMismatch`). U nepozměněného EXE je
očekávané `UnknownError` s vysvětlením nedůvěryhodného kořene certifikátu;
kryptografická správnost podpisu se ověřuje odděleně a není důvěrou vydavatele.

Současný EXE vznikl podepsáním předchozího přesně ověřeného souboru, bez nového
exportu hry. Porovnání bajtů potvrdilo změnu pouze PE checksumu, položky tabulky
certifikátů a připojení podpisu. Následoval skutečný start s grafikou i bez ní,
obě servisní mise, zvuky a obnovení odložené směny. Testovací start používá
`--test-world --export-smoke` a existující `SaveManager.path_override`.
Původní úplná regrese 63/63 je označená jako ověření před podpisem; nebyla
znovu spuštěná. Surové výsledky: [windows-debug-signing](windows-debug-signing/).

[Godot a podepisování Windows exportu](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html#code-signing)
· [Microsoft Set-AuthenticodeSignature](https://learn.microsoft.com/powershell/module/microsoft.powershell.security/set-authenticodesignature).
