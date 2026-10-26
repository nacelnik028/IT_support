Here is the result of "fetch" for the Page with URL https://app.notion.com/p/405bceb1e413819ab91ac29b51c88dae as of 2026-10-26T15:28:14.608Z:
<page url="https://app.notion.com/p/405bceb1e413819ab91ac29b51c88dae">
<ancestor-path>
<parent-page url="https://app.notion.com/p/405bceb1e4138096aa61c91a2e13c3cf" title="Hra"/>
</ancestor-path>
<properties>
{"title":"HTML – základy tvorby webu"}
</properties>
<iconMetadata>null</iconMetadata>
<content>
HTML (HyperText Markup Language) je <b>značkovací jazyk</b>, který určuje strukturu webové stránky. CSS se stará o vzhled a JavaScript o interakci. HTML se skládá ze značek (<i>tagů</i>) a jejich atributů.

<callout icon="💡" color="blue_bg">
Pro vyzkoušení vytvoř soubor <code>index.html</code>, vlož do něj ukázkový kód, ulož ho a otevři v prohlížeči. Většina párových značek má začátek a konec: <code><p>Text</p></code>. Například <code><img></code> nebo <code><br></code> uzavírací značku nepotřebují.
</callout>

## 1. Kostra HTML dokumentu

```html
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moje první stránka</title>
</head>
<body>
    <h1>Ahoj, světe!</h1>
    <p>Tohle je moje první webová stránka.</p>
</body>
</html>
```

| Značka | Význam |
| --- | --- |
| <code><!DOCTYPE html></code> | Prohlížeči říká, že jde o moderní HTML |
| <code><html lang="cs"></code> | Kořen dokumentu, jazyk stránky |
| <code><head></code> | Metadata a nastavení stránky |
| <code><meta charset="UTF-8"></code> | Správné zobrazení českých znaků |
| <code><meta name="viewport" ...></code> | Přizpůsobení mobilním obrazovkám |
| <code><title></code> | Titulek na kartě prohlížeče |
| <code><body></code> | Viditelný obsah webu |

## 2. Nadpisy, text a oddělovače

| Značka | Co dělá |
| --- | --- |
| <code><h1></code> až <code><h6></code> | Nadpisy od nejdůležitějšího k nejméně důležitému |
| <code><p></code> | Odstavec |
| <code><strong></code> | Důležitý / obvykle tučný text |
| <code><em></code> | Zdůraznění / obvykle kurzíva |
| <code><br></code> | Zalomí řádek |
| <code><hr></code> | Tematický oddělovač |
| <code><mark></code> | Zvýraznění textu |
| <code><code></code> a <code><pre></code> | Kód / předformátovaný blok textu |

```html
<h1>Moje stránka</h1>
<h2>O mně</h2>
<p>Učím se <strong>HTML</strong> a <em>baví mě to</em>.</p>
<p>První řádek<br>Druhý řádek</p>
<hr>
<p>Tohle je <mark>důležité</mark>.</p>
```

Používej nadpisy podle významu, nejen podle velikosti písma.

## 3. Odkazy a obrázky

```html
<a href="https://www.wikipedia.org/">Navštiv Wikipedii</a>

<a href="https://www.wikipedia.org/"
   target="_blank" rel="noopener noreferrer">
   Otevřít v nové kartě
</a>

<img src="obrazek.jpg" alt="Modré kolo opřené o strom" width="300">
```

- <code>href</code> = cílová adresa odkazu (může být i <code>kontakt.html</code> nebo <code>#sekce</code>).
- <code>src</code> = cesta k obrázku; <code>alt</code> = textový popis obrázku pro přístupnost a případné nenahrání.
- <code>target="_blank"</code> otevře novou kartu. U externích odkazů je vhodné i <code>rel="noopener noreferrer"</code>.
- <code>width</code> a <code>height</code> určují rozměry. Obrázek musí opravdu existovat v uvedené cestě.

## 4. Seznamy

<code><ul></code> vytváří nečíslovaný seznam; <code><ol></code> číslovaný. Každá položka je <code><li></code>.

```html
<h2>Co se učím</h2>
<ul>
    <li>HTML</li>
    <li>CSS</li>
    <li>Python</li>
</ul>

<h2>Můj postup</h2>
<ol>
    <li>Napíšu kód.</li>
    <li>Uložím soubor.</li>
    <li>Otevřu ho v prohlížeči.</li>
</ol>
```

## 5. Tabulky

| Značka | Význam |
| --- | --- |
| <code><table></code> | Tabulka |
| <code><tr></code> | Řádek |
| <code><th></code> | Záhlaví sloupce nebo řádku |
| <code><td></code> | Datová buňka |
| <code><caption></code> | Název tabulky |
| <code><thead></code>, <code><tbody></code> | Oddíly tabulky |

```html
<table>
    <caption>Rozvrh</caption>
    <thead>
        <tr><th>Předmět</th><th>Den</th></tr>
    </thead>
    <tbody>
        <tr><td>Informatika</td><td>Pondělí</td></tr>
        <tr><td>Matematika</td><td>Úterý</td></tr>
    </tbody>
</table>
```

Tabulky používej pro tabulková data, ne pro rozložení celé stránky.

## 6. Kontejnery a významové (sémantické) značky

| Značka | Účel |
| --- | --- |
| <code><div></code> | Obecný blokový kontejner |
| <code><span></code> | Obecný řádkový kontejner |
| <code><header></code> | Hlavička stránky nebo sekce |
| <code><nav></code> | Navigační odkazy |
| <code><main></code> | Hlavní obsah stránky |
| <code><section></code> | Tematická sekce |
| <code><article></code> | Samostatný článek/příspěvek |
| <code><aside></code> | Doplňující obsah |
| <code><footer></code> | Patička |

```html
<header>
    <h1>Můj blog</h1>
    <nav><a href="#novinky">Novinky</a></nav>
</header>
<main>
    <section id="novinky">
        <h2>Novinky</h2>
        <article>
            <h3>Můj první článek</h3>
            <p>Právě se učím HTML!</p>
        </article>
    </section>
</main>
<footer><p>© 2026 Můj web</p></footer>
```

## 7. Atributy: id, class, title a další

Atributy píšeme do otevírací značky ve tvaru <code>nazev="hodnota"</code>.

| Atribut | Co znamená |
| --- | --- |
| <code>id="kontakt"</code> | Jedinečný identifikátor prvku |
| <code>class="karta"</code> | Třída používaná zejména v CSS |
| <code>title="Nápověda"</code> | Doplňující informace při najetí |
| <code>style="color: red;"</code> | CSS přímo na prvku (spíše pro ukázky) |
| <code>hidden</code> | Skryje prvek |
| <code>required</code> | Povinné pole formuláře |
| <code>disabled</code> | Zakázaný vstup nebo ovládací prvek |

```html
<p id="uvod" class="dulezite" title="Úvodní text">
    Vítej na stránce!
</p>
<a href="#uvod">Přejít na úvod</a>
```

## 8. Formuláře a vstupní pole

| Značka/atribut | Význam |
| --- | --- |
| <code><form></code> | Formulář |
| <code><label for="jmeno"></code> | Popisek napojený na <code>id</code> vstupu |
| <code><input type="text"></code> | Jednořádkový text |
| <code>type="email"</code> | E-mailová adresa |
| <code>type="number"</code> | Číslo |
| <code>type="password"</code> | Skryté znaky |
| <code>type="checkbox"</code> | Zaškrtávátko |
| <code>type="radio"</code> | Výběr jedné možnosti ze skupiny |
| <code><textarea></code> | Víceřádkový text |
| <code><select></code> a <code><option></code> | Rozbalovací nabídka |
| <code><button type="submit"></code> | Odeslání formuláře |

```html
<form action="/odeslat" method="post">
    <label for="jmeno">Jméno:</label>
    <input id="jmeno" name="jmeno" type="text" required>

    <label for="email">E-mail:</label>
    <input id="email" name="email" type="email" required>

    <label for="zprava">Zpráva:</label>
    <textarea id="zprava" name="zprava" rows="4"></textarea>

    <label for="tema">Téma:</label>
    <select id="tema" name="tema">
        <option value="dotaz">Dotaz</option>
        <option value="pozdrav">Pozdrav</option>
    </select>

    <button type="submit">Odeslat</button>
</form>
```

<code>action</code> určuje adresu, kam se data posílají; <code>method="get"</code> posílá data v URL a <code>method="post"</code> v těle požadavku. Samotné HTML nedokáže data zpracovat ani poslat e-mail: k tomu je potřeba fungující server nebo jiná služba. Ukázková adresa <code>/odeslat</code> je jen zástupná.

## 9. HTML a CSS: barvy, velikosti, mezery

CSS není HTML příkaz, ale s HTML úzce souvisí. Pravidlo <code>selektor { vlastnost: hodnota; }</code> nastavuje vzhled vybraných prvků.

```html
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f7ff;
        color: #222;
    }
    h1 { color: royalblue; }
    .karta {
        padding: 16px;
        margin: 12px 0;
        border: 1px solid #bbb;
        border-radius: 8px;
    }
    #hlavni { max-width: 700px; }
</style>

<div id="hlavni" class="karta">
    <h1>Vítej!</h1>
    <p>Tohle je barevná karta.</p>
</div>
```

| CSS zápis | Význam |
| --- | --- |
| <code>color</code> | Barva textu |
| <code>background-color</code> | Barva pozadí |
| <code>font-size</code> | Velikost písma |
| <code>padding</code> | Vnitřní odsazení |
| <code>margin</code> | Vnější odsazení |
| <code>border</code> | Ohraničení |
| <code>display: flex</code> | Flexibilní rozložení |
| <code>display: grid</code> | Mřížkové rozložení |

Vlastní styly je přehlednější ukládat do souboru <code>style.css</code> a připojit v <code><head></code>:

```html
<link rel="stylesheet" href="style.css">
```

## 10. HTML a JavaScript

JavaScript přidá stránce reakce na události, například kliknutí.

```html
<button id="tlacitko">Klikni na mě</button>
<p id="vysledek">Zatím nic.</p>

<script>
    document.getElementById("tlacitko").addEventListener("click", function () {
        document.getElementById("vysledek").textContent = "Ahoj!";
    });
</script>
```

Externí skript můžeš připojit pomocí <code><script src="script.js" defer></script></code>, obvykle v <code><head></code>.

## 11. Speciální znaky a komentáře

V běžném HTML textu se některé znaky zapisují pomocí entit:

| Entita | Výsledek |
| --- | --- |
| <code>&lt;</code> | Znak menší než |
| <code>&gt;</code> | Znak větší než |
| <code>&amp;</code> | Ampersand |
| <code>&quot;</code> | Uvozovky |
| <code>&nbsp;</code> | Nezalomitelná mezera |

```html
<!-- Tento komentář se na stránce nezobrazí. -->
<p>HTML značka se píše třeba jako &lt;p&gt;.</p>
```

## 12. Hotová mini stránka 🧩

Zkopíruj celý příklad do <code>index.html</code> a otevři ho.

```html
<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Moje vizitka</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        main { max-width: 600px; margin: auto; }
        h1 { color: teal; }
        .karta { background: #eef8f7; padding: 20px; border-radius: 12px; }
    </style>
</head>
<body>
    <main>
        <div class="karta">
            <h1>Ahoj, já jsem Alex!</h1>
            <p>Učím se tvořit webové stránky.</p>
            <h2>Moje zájmy</h2>
            <ul>
                <li>Programování</li>
                <li>Hry</li>
                <li>Hudba</li>
            </ul>
            <a href="https://developer.mozilla.org/" target="_blank"
               rel="noopener noreferrer">Nauč se víc o webu</a>
        </div>
    </main>
</body>
</html>
```

## 13. Procvičování

- [ ] Vytvoř <code>index.html</code> s nadpisem, dvěma odstavci a seznamem tří koníčků.
- [ ] Přidej obrázek s výstižným <code>alt</code> a odkaz na oblíbenou stránku.
- [ ] Vytvoř tabulku s alespoň dvěma řádky a dvěma sloupci.
- [ ] Přidej formulář se jménem a e-mailem (odeslání nemusí fungovat).
- [ ] Připoj <code>style.css</code> a změň barvu nadpisu, pozadí i odsazení.

<b>Časté chyby:</b> chybějící uzavírací značka, špatná cesta k obrázku, chybějící <code>alt</code>, nespojené <code><label></code> a <code><input></code>, více prvků se stejným <code>id</code>. HTML opisuj v souboru s příponou <code>.html</code>.

<b>Další studium:</b> [MDN Web Docs – HTML](https://developer.mozilla.org/en-US/docs/Web/HTML) a [MDN – CSS](https://developer.mozilla.org/en-US/docs/Web/CSS).
</content>
</page>
