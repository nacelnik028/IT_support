# Jak nainstalovat IT Support Simulator do PICO 4

Tento postup je pro běžný **PICO 4** a Windows počítač. Hra se nainstaluje přímo
do headsetu. Po instalaci můžeš USB odpojit a hrát samostatně.

Potřebuješ zapnutý headset, oba ovladače a **USB kabel pro přenos dat**.

## 1. Najdi hotovou hru

V projektu je připravený soubor:

**[builds/pico4/ITSupportSimulator-PICO4.apk](builds/pico4/ITSupportSimulator-PICO4.apk)**

Pokud hru stahuješ z GitHubu, otevři
[soubor APK v repozitáři](https://github.com/nacelnik028/IT_support/blob/main/builds/pico4/ITSupportSimulator-PICO4.apk)
a zvol **Download raw file / Stáhnout**. Při použití níže uvedených příkazů
ponech APK ve složce `builds/pico4` uvnitř projektu.

## 2. Zapni vývojářský režim v headsetu

V PICO 4 proveď tyto kroky:

1. Otevři **Nastavení / Settings**.
2. Přejdi na **Obecné / General → Informace / About**.
3. Opakovaně klikni na **Verze softwaru / Software Version**, dokud se v nabídce
   neobjeví **Vývojář / Developer**.
4. Otevři **Developer** a zapni **USB Debug / USB debugging**.

Názvy se mohou mírně lišit podle jazyka a verze PICO OS. Postup vychází
z [oficiálního návodu PICO](https://developer.picoxr.com/document/unreal/test-and-build/).

## 3. Připoj PICO k počítači

1. Připoj headset datovým USB kabelem k počítači.
2. Nasaď si headset a potvrď dotaz **Povolit ladění USB / Allow USB debugging**.
3. U svého počítače můžeš označit **Vždy povolit z tohoto počítače**.
4. Pokud se nabídne režim USB připojení, zvol **Přenos souborů / File Transfer**.

## 4. Otevři PowerShell ve složce projektu

V Průzkumníku otevři složku **IT_support**, ve které je `project.godot`
a tento návod. Klikni pravým tlačítkem do volného místa a zvol
**Otevřít v terminálu** nebo **Otevřít okno PowerShellu zde**.

Na počítači, kde byl projekt připraven, je ADB již v Android SDK.
Do PowerShellu postupně vlož:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb version
```

Měla by se vypsat verze **Android Debug Bridge**.

**Pokud ADB na svém počítači nemáš:** stáhni **SDK Platform-Tools for Windows**
z [oficiální stránky Androidu](https://developer.android.com/tools/releases/platform-tools),
rozbal ZIP například tak, aby vznikl soubor
`C:\Android\platform-tools\adb.exe`, a místo prvního řádku použij:

```powershell
$adb = 'C:\Android\platform-tools\adb.exe'
& $adb version
```

Ve všech dalších příkazech používej stejné otevřené okno PowerShellu, aby
zůstala nastavená proměnná `$adb`.

## 5. Ověř připojení a nainstaluj hru

Nejprve spusť:

```powershell
& $adb devices -l
```

Pod `List of devices attached` se musí objevit jeden headset se stavem
**`device`**, například:

```text
List of devices attached
SERIOVE_CISLO    device    model:PICO_4
```

Potom nainstaluj APK:

```powershell
& $adb install -r '.\builds\pico4\ITSupportSimulator-PICO4.apk'
```

Počkej na **`Success`**. Parametr `-r` umožní aktualizovat již nainstalovanou
hru a zachovat její data, pokud má nová verze stejný podpis.
Viz [dokumentace instalace přes ADB](https://developer.android.com/tools/adb#move).

## 6. Spusť hru

V headsetu otevři **knihovnu aplikací** a najdi **IT Support Simulator**.
Pokud jej nevidíš, podívej se i do sekce vlastních nebo neznámých aplikací,
pokud ji tvoje verze systému nabízí.

Hru můžeš spustit také přímo z PowerShellu:

```powershell
& $adb shell am start -n 'cz.academy.itsupport/com.godot.game.GodotAppLauncher'
```

APK spouští VR přímo. Pro běžné hraní potom počítač ani USB kabel nepotřebuješ.

## 7. První ovládání

| Ovládání | Co dělá |
|---|---|
| Drž klik levého joysticku, zamiř na podlahu a uvolni | Teleportace |
| Pravý joystick do strany | Otáčení po krocích |
| Trigger | Interakce se zařízením a klikání na monitor |
| Grip u náhradního disku | Uchopení disku |
| B/Y nebo dostupné tlačítko menu | Pauza a návrat do hry |
| A/X | Zadání mise; při otevřeném monitoru jeho přemístění před pohled |

V pauze otevři **Komfort VR / výška / pohyb**. Tam zapneš plynulý pohyb levým
joystickem, upravíš otáčení nebo nastavíš hraní vsedě a výšku očí.
Po výběru textového pole na monitoru se zobrazí virtuální klávesnice.

## Když se něco nedaří

| Problém | Co udělat |
|---|---|
| `unauthorized` | Nasaď si headset a potvrď povolení ladění USB. Potom zopakuj `& $adb devices -l`. |
| Pod seznamem není žádné zařízení | Zkontroluj zapnuté USB debugging, jiný USB port a datový kabel. Nabíjecí kabel bez dat nestačí. Ve Správci zařízení Windows ověř přítomnost PICO ADB rozhraní; podrobnosti uvádí [PICO](https://developer.picoxr.com/document/unreal/pdc-faq/). |
| `offline` | Odpoj a znovu připoj USB, probuď headset a zopakuj kontrolu zařízení. |
| Příkaz nenajde `adb.exe` | Oprav cestu v proměnné `$adb` podle kroku 4. |
| Příkaz nenajde APK | Otevři terminál ve složce `IT_support` a ověř, že soubor existuje v `builds/pico4`. |
| `more than one device/emulator` | Odpoj ostatní zařízení/emulátory, nebo přidej za `$adb` parametr `-s 'SERIOVE_CISLO'` před `install` či `shell`. |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Nainstalovaná verze má jiný podpis. Nejprve si podle README vyexportuj postup. Teprve po záloze můžeš starou aplikaci odinstalovat a APK nainstalovat znovu. Odinstalace smaže její místní data. |
| Hru nevidíš v knihovně | Použij příkaz pro spuštění z kroku 6. |
| Hra hlásí nedostupné OpenXR, má černý obraz nebo nesleduje hlavu/ovladače | Poznamenej verzi PICO OS a popis problému. Je potřeba ověřit běh na konkrétním headsetu; samotné úspěšné nainstalování tracking nepotvrzuje. |

Přenos herního postupu mezi Windows a PICO popisuje
[README – Přenos uloženého postupu](README.md#přenos-uloženého-postupu-mezi-pc-a-pico).

**Stav ověření:** APK bylo sestaveno a zkontrolováno z hlediska podpisu,
ARM64 a PICO/OpenXR manifestu. Fyzický PICO 4 při přípravě nebyl připojený;
skutečný tracking a výkon na headsetu zatím nejsou otestované.
