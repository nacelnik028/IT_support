Here is the result of "fetch" for the Page with URL https://app.notion.com/p/405bceb1e4138119bc9ad0c218037325 as of 2026-10-26T15:28:04.556Z:
<page url="https://app.notion.com/p/405bceb1e4138119bc9ad0c218037325">
<ancestor-path>
<parent-page url="https://app.notion.com/p/405bceb1e4138096aa61c91a2e13c3cf" title="Hra"/>
</ancestor-path>
<properties>
{"title":"Python – základy programování"}
</properties>
<iconMetadata>null</iconMetadata>
<content>
# Základy programování v Pythonu 🐍

Python je čitelný programovací jazyk vhodný pro začátečníky. Příkazy se vykonávají shora dolů. Odsazení (obvykle 4 mezery) určuje, které příkazy patří do podmínky, cyklu nebo funkce.

<callout icon="💡" color="blue_bg">
Kód z příkladů spouštěj v Pythonu 3. Každý blok si zkus upravit a znovu spustit. Text za znakem <code>#</code> je komentář, který Python nevykonává.
</callout>

## 1. První příkazy: výpis a komentáře

| Příkaz | Co dělá |
| --- | --- |
| <code>print(...)</code> | Vypíše text nebo hodnotu |
| <code># komentář</code> | Poznámka pro programátora |
| <code>input(...)</code> | Načte text od uživatele |

```py
# Můj první program
print("Ahoj, světe!")
jmeno = input("Jak se jmenuješ? ")
print("Ahoj,", jmeno)
```

## 2. Proměnné a datové typy

Proměnná uchovává hodnotu. V Pythonu nepíšeš typ před názvem proměnné. Názvy rozlišují velká a malá písmena (<code>vek</code> a <code>Vek</code> jsou různé).

| Typ | Příklad | Význam |
| --- | --- | --- |
| <code>int</code> | <code>vek = 15</code> | Celé číslo |
| <code>float</code> | <code>cena = 19.5</code> | Desetinné číslo (s tečkou) |
| <code>str</code> | <code>jmeno = "Eva"</code> | Textový řetězec |
| <code>bool</code> | <code>hotovo = True</code> | Pravda/nepravda |
| <code>None</code> | <code>vysledek = None</code> | Zatím žádná hodnota |

```py
vek = 15
cena = 49.90
jmeno = "Anna"
student = True
print(jmeno, vek)
print(type(vek))  # <class 'int'>

# Převody typů
cislo = int("42")
desetinne = float("3.14")
text = str(123)
```

<callout icon="⚠️" color="yellow_bg">
<code>input()</code> vždy vrací text. Pro počítání s věkem použij například <code>vek = int(input("Zadej věk: "))</code>. Zadání nečíselného textu vyvolá chybu <code>ValueError</code>.
</callout>

## 3. Operátory a porovnávání

| Operátor | Význam | Příklad |
| --- | --- | --- |
| <code>+</code>, <code>-</code>, <code>*</code>, <code>/</code> | Sčítání, odčítání, násobení, dělení | <code>7 / 2</code> → <code>3.5</code> |
| <code>//</code> | Celočíselné dělení | <code>7 // 2</code> → <code>3</code> |
| <code>%</code> | Zbytek po dělení | <code>7 % 2</code> → <code>1</code> |
| <code>**</code> | Mocnina | <code>2 ** 3</code> → <code>8</code> |
| <code>==</code>, <code>!=</code> | Rovná se, nerovná se | <code>3 == 3</code> → <code>True</code> |
| <code>></code>, <code><</code>, <code>>=</code>, <code><=</code> | Porovnání | <code>5 >= 2</code> → <code>True</code> |
| <code>and</code>, <code>or</code>, <code>not</code> | Logické operátory | <code>True and False</code> → <code>False</code> |
| <code>+=</code>, <code>-=</code> | Změna proměnné | <code>skore += 1</code> |

```py
a = 10
b = 3
print(a + b)   # 13
print(a % b)   # 1
print(a > b)   # True
print(a > 5 and b < 5)  # True

skore = 0
skore += 1
```

## 4. Textové řetězce (str)

| Příkaz | Co dělá |
| --- | --- |
| <code>len(text)</code> | Počet znaků |
| <code>text.upper()</code> / <code>text.lower()</code> | Velká / malá písmena |
| <code>text.strip()</code> | Odstraní mezery na krajích |
| <code>text.replace("a", "o")</code> | Nahradí část textu |
| <code>text.split(",")</code> | Rozdělí text do seznamu |
| <code>text[0]</code>, <code>text[-1]</code> | První / poslední znak |
| <code>text[1:4]</code> | Výřez znaků na pozicích 1 až 3 |

```py
jmeno = " Klara "
print(jmeno.strip().upper())  # KLARA
slovo = "Python"
print(slovo[0])   # P
print(slovo[:3])  # Pyt
vek = 16
print(f"Jmenuji se {jmeno.strip()} a je mi {vek} let.")
```

Pozor: počítání pozic (indexů) začíná od <code>0</code>. Koncový index ve výřezu se nezahrnuje.

## 5. Seznamy (list)

Seznam uchovává více hodnot v pořadí. Lze ho měnit.

| Příkaz | Co dělá |
| --- | --- |
| <code>ovoce = ["jablko", "banán"]</code> | Vytvoří seznam |
| <code>ovoce[0]</code> / <code>ovoce[-1]</code> | První / poslední prvek |
| <code>ovoce.append("hruška")</code> | Přidá prvek na konec |
| <code>ovoce.extend(["kiwi", "švestka"])</code> | Přidá více prvků |
| <code>ovoce.insert(1, "mango")</code> | Vloží prvek na index 1 |
| <code>ovoce.remove("banán")</code> | Odebere první danou hodnotu |
| <code>ovoce.pop()</code> | Odebere a vrátí poslední prvek |
| <code>len(ovoce)</code> | Počet prvků |
| <code>"kiwi" in ovoce</code> | Zjistí, zda prvek existuje |
| <code>ovoce.sort()</code> / <code>ovoce.reverse()</code> | Seřadí / obrátí pořadí |

```py
cisla = [5, 2, 9, 1]
print(cisla[0])  # 5
cisla.append(7)
cisla.sort()
print(cisla)     # [1, 2, 5, 7, 9]
print(len(cisla))
print(sum(cisla))
print(max(cisla))

# Nový seznam pomocí list comprehension
dvojnasobky = [x * 2 for x in cisla]
print(dvojnasobky)
```

Výřez seznamu funguje podobně jako u textu: <code>cisla[1:3]</code>. Seznam může obsahovat i různá datová typu, ale pro přehlednost je často lepší držet jeden typ.

## 6. Slovníky, n-tice a množiny

| Struktura | Zápis | Kdy použít |
| --- | --- | --- |
| <code>dict</code> (slovník) | <code>{"jmeno": "Eva", "vek": 16}</code> | Údaje pod pojmenovanými klíči |
| <code>tuple</code> (n-tice) | <code>(10, 20)</code> | Pořadí hodnot, které nechceš měnit |
| <code>set</code> (množina) | <code>{1, 2, 3}</code> | Unikátní hodnoty bez garantovaného pořadí |

```py
hrac = {"jmeno": "Eva", "skore": 10}
print(hrac["jmeno"])
hrac["skore"] += 5
hrac["uroven"] = 2
print(hrac.get("zivoty", 3))  # výchozí hodnota 3

souradnice = (10, 20)
unikatni = set([1, 1, 2, 3])
unikatni.add(4)
print(unikatni)
```

## 7. Podmínky: if, elif, else

Podmínka rozhoduje, který blok kódu se vykoná. Za podmínkou je dvojtečka a následující řádek je odsazený.

```py
vek = int(input("Kolik ti je let? "))

if vek >= 18:
    print("Jsi dospělý.")
elif vek >= 15:
    print("Je ti alespoň 15.")
else:
    print("Je ti méně než 15.")
```

## 8. Cykly: for a while

<code>for</code> opakuje kód nad položkami nebo čísly. <code>range(start, stop, step)</code> nezahrnuje hodnotu <code>stop</code>.

```py
for i in range(5):
    print(i)   # 0, 1, 2, 3, 4

for i in range(2, 11, 2):
    print(i)   # 2, 4, 6, 8, 10

ovoce = ["jablko", "banán", "kiwi"]
for index, polozka in enumerate(ovoce):
    print(index, polozka)
```

<code>while</code> opakuje kód, dokud je podmínka pravdivá. Dávej pozor na nekonečný cyklus.

```py
pocitadlo = 3
while pocitadlo > 0:
    print(pocitadlo)
    pocitadlo -= 1

for cislo in range(10):
    if cislo == 3:
        continue  # přeskočí tuto iteraci
    if cislo == 7:
        break     # ukončí cyklus
    print(cislo)
```

## 9. Funkce: def, parametry a return

Funkce je pojmenovaná část programu, kterou můžeš opakovaně volat. <code>return</code> vrátí výsledek.

```py
def secti(a, b):
    return a + b

def pozdrav(jmeno="kamaráde"):
    print(f"Ahoj, {jmeno}!")

vysledek = secti(3, 5)
print(vysledek)  # 8
pozdrav("Petře")
pozdrav()
```

## 10. Užitečné vestavěné funkce

| Funkce | Použití |
| --- | --- |
| <code>len(x)</code> | Délka textu či kolekce |
| <code>sum(cisla)</code> | Součet čísel |
| <code>min(x)</code>, <code>max(x)</code> | Nejmenší a největší hodnota |
| <code>sorted(x)</code> | Vrátí nově seřazený seznam |
| <code>abs(-7)</code> | Absolutní hodnota |
| <code>round(3.14159, 2)</code> | Zaokrouhlení na 2 desetinná místa |
| <code>range(5)</code> | Posloupnost 0 až 4 |
| <code>enumerate(x)</code> | Index i hodnota při průchodu |
| <code>zip(a, b)</code> | Spojí položky kolekcí po dvojicích |

## 11. Import knihoven a náhodná čísla

```py
import math
import random

print(math.sqrt(81))  # 9.0
print(random.randint(1, 6))  # náhodné číslo od 1 do 6
barvy = ["červená", "modrá", "zelená"]
print(random.choice(barvy))
```

## 12. Ošetření chyb: try / except

```py
try:
    vek = int(input("Zadej svůj věk: "))
    print(f"Za rok ti bude {vek + 1}.")
except ValueError:
    print("Zadej prosím celé číslo.")
```

## 13. Soubor: čtení a zápis

```py
# Vytvoří nebo přepíše soubor
with open("poznamky.txt", "w", encoding="utf-8") as soubor:
    soubor.write("Ahoj z Pythonu!\n")

# Přečte obsah souboru
with open("poznamky.txt", "r", encoding="utf-8") as soubor:
    obsah = soubor.read()
print(obsah)
```

<code>"w"</code> přepisuje, <code>"a"</code> přidává na konec a <code>"r"</code> čte. <code>with</code> soubor automaticky zavře.

## 14. Malý projekt: hádání čísla 🎲

Program vylosuje číslo od 1 do 10. Hráč hádá, dokud se netrefí.

```py
import random

tajne = random.randint(1, 10)
pokusy = 0

while True:
    try:
        tip = int(input("Hádej číslo od 1 do 10: "))
    except ValueError:
        print("Zadej číslo.")
        continue

    pokusy += 1
    if tip < tajne:
        print("Zkus vyšší číslo.")
    elif tip > tajne:
        print("Zkus nižší číslo.")
    else:
        print(f"Správně! Uhodl/a jsi to na {pokusy}. pokus.")
        break
```

## 15. Procvičování

- [ ] Vytvoř proměnné <code>jmeno</code> a <code>vek</code> a vypiš je pomocí f-stringu.
- [ ] Vytvoř seznam pěti čísel, přidej šesté a vypiš jejich součet.
- [ ] Vypiš všechna sudá čísla od 2 do 20 pomocí <code>for</code>.
- [ ] Napiš funkci <code>obsah_obdelniku(sirka, vyska)</code>, která vrátí součin.
- [ ] Rozšiř hru o omezení na pět pokusů.

<b>Časté chyby:</b> <code>=</code> přiřazuje, <code>==</code> porovnává; nezapomeň na dvojtečku za <code>if</code>, <code>for</code>, <code>while</code> a <code>def</code>; dodržuj odsazení; index prvního prvku je 0.
</content>
</page>
