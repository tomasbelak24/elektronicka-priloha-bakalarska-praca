/**
 * Funkcia toggleMenu prepína viditeľnosť navigačného menu.
 *
 * Funkcia nájde HTML element s ID "nav-menu" a skontroluje jeho aktuálny
 * štýl zobrazenia. Ak je menu viditeľné (display je "block"), nastaví jeho
 * zobrazenie na "none" (skryté). Ak je menu skryté, nastaví jeho zobrazenie
 * na "block" (viditeľné).
 *
 * Príklad použitia:
 * <button onclick="toggleMenu()">Toggle Menu</button>
 * <div id="nav-menu" style="display: none;">Menu Content</div>
 */
function toggleMenu() {
    var menu = document.getElementById("nav-menu");
    if (menu.style.display === "block") {
        menu.style.display = "none";
    } else {
        menu.style.display = "block";
    }
}


/**
 * Funkcia capitalizeFirstLetter zmení prvé písmeno reťazca na veľké písmeno.
 *
 * Argumenty:
 * s (str): Reťazec, ktorý sa má upraviť. Ak je reťazec prázdny alebo undefined, funkcia vráti prázdny reťazec.
 *
 * Návratová hodnota:
 * str: Upravený reťazec s prvým písmenom vo veľkom písmene. Ak je vstupný reťazec prázdny, vráti prázdny reťazec.
 *
 * Príklad použitia:
 * console.log(capitalizeFirstLetter("hello")); // "Hello"
 * console.log(capitalizeFirstLetter("")); // ""
 * console.log(capitalizeFirstLetter(null)); // ""
 */
function capitalizeFirstLetter(s) {
    // Ak je reťazec prázdny alebo undefined, vráti prázdny reťazec
    if (!s) return "";
    // Zmení prvé písmeno na veľké a vráti upravený reťazec
    return s.charAt(0).toUpperCase() + s.slice(1);
}


/**
 * Funkcia generateNodeDetailsHtml generuje HTML reťazec s podrobnosťami o športovisku na základe poskytnutých údajov.
 *
 * Argumenty:
 * nodeDetails (Array): Pole obsahujúce dva prvky:
 *   - Prvý prvok je objekt, ktorý obsahuje údaje pre jednotlivé stĺpce.
 *   - Druhý prvok je pole reťazcov s usporiadanými názvami stĺpcov.
 *
 * Návratová hodnota:
 * str: HTML reťazec obsahujúci podrobnosti o uzle.
 *
 * Príklad použitia:
 * const nodeDetails = [
 *   { "názov": "Športovisko 1", "Typ športoviska": "Futbalové ihrisko", "Status": "Aktívne" },
 *   ["názov", "Typ športoviska", "Status"]
 * ];
 * console.log(generateNodeDetailsHtml(nodeDetails));
 */
function generateNodeDetailsHtml(nodeDetails) {
    const columnData = nodeDetails[0]; // Prvý prvok: objekt obsahujúci údaje pre stĺpce
    const orderedColumnNames = nodeDetails[1]; // Druhý prvok: pole obsahujúce usporiadané názvy stĺpcov
    let htmlOutput = '';

    // Iterácia cez usporiadaný zoznam názvov stĺpcov
    orderedColumnNames.forEach(columnName => {
        const columnValue = columnData[columnName];

        // Kontrola, či hodnota stĺpca nie je null
        if (columnValue !== null) {
            // Generovanie HTML pre každý stĺpec, ktorý nie je null
            htmlOutput += `
<div class="node-detail-column">
    <div class="node-detail-name">
        <span>${capitalizeFirstLetter(columnName)}:</span>
    </div>
    <div class="node-detail-value">
        <span>${columnValue}</span>
    </div>
</div>
`;
        }
    });

    return htmlOutput;
}


/**
 * Funkcia sendNodeID načíta podrobnosti o športovisku zo servera a zobrazí ich v bočnom paneli.
 *
 * Argumenty:
 * nodeID (str): ID uzla, pre ktorý sa majú načítať podrobnosti.
 *
 * Postup:
 * 1. Vykoná HTTP GET požiadavku na URL `/node/{nodeID}` pomocou fetch API.
 * 2. Po prijatí odpovede konvertuje odpoveď na JSON formát.
 * 3. Vygeneruje HTML obsah na základe prijatých údajov a zobrazí ho v elemente s ID 'node-details'.
 * 4. Otvorí bočný panel s podrobnosťami uzla.
 * 5. Ak dôjde k chybe, vypíše chybu do konzoly.
 *
 * Príklad použitia:
 * sendNodeID(1);
 */
function sendNodeID(nodeID) {
    // Vykonanie fetch požiadavky na URL `/node/{nodeID}`
    fetch(`/node/${nodeID}`)
        .then(response => response.json()) // Konverzia odpovede na JSON formát
        .then(data => {
            // Vygenerovanie HTML obsahu na základe prijatých údajov
            document.getElementById('node-details').innerHTML = generateNodeDetailsHtml(data);
            // Otvorenie bočného panelu s podrobnosťami
            openSidebarDetails();
        })
        .catch(error => console.error('Error:', error)); // Vypísanie chyby do konzoly v prípade zlyhania
}


/**
 * Funkcia openSidebar otvorí bočný panel a nastaví jeho šírku.
 *
 * Argumenty:
 * Táto funkcia neprijíma žiadne argumenty.
 *
 * Postup:
 * 1. Zistí šírku okna prehliadača pomocou window.innerWidth.
 * 2. Vypočíta šírku bočného panelu ako minimum z hodnoty šírky okna a 450 pixelov.
 * 3. Nastaví šírku HTML elementu s ID "sidebar" na vypočítanú hodnotu.
 *
 * Príklad použitia:
 * openSidebar();
 */
function openSidebar() {
    // Zistenie šírky okna prehliadača
    var width = Math.min(window.innerWidth, 450);
    // Nastavenie šírky bočného panelu
    document.getElementById("sidebar").style.width = width + "px";
}


/**
 * Funkcia sendNodeIDandOpenSideBar načíta podrobnosti o športovisku, zorbazí ich v bočnom paneli a zároveň otvorí bočný panel.
 *
 * Argumenty:
 * nodeID (str): ID uzla, pre ktorý sa majú načítať podrobnosti.
 *
 * Postup:
 * 1. Zavolá funkciu sendNodeID(nodeID), ktorá načíta podrobnosti o uzle a zobrazí ich v bočnom paneli.
 * 2. Zavolá funkciu openSidebar(), ktorá otvorí bočný panel a nastaví jeho šírku.
 *
 * Príklad použitia:
 * sendNodeIDandOpenSideBar(1);
 */
function sendNodeIDandOpenSideBar(nodeID) {
    // Načíta podrobnosti o uzle a zobrazí ich v bočnom paneli
    sendNodeID(nodeID);
    // Otvorí bočný panel a nastaví jeho šírku
    openSidebar();
}


/**
 * Funkcia closeSidebar zatvorí bočný panel nastavením jeho šírky na 0.
 *
 * Argumenty:
 * Táto funkcia neprijíma žiadne argumenty.
 *
 * Postup:
 * 1. Nájde HTML element s ID "sidebar".
 * 2. Nastaví štýl šírky elementu na "0", čím sa bočný panel skryje.
 *
 * Príklad použitia:
 * closeSidebar();
 */
function closeSidebar() {
    // Nájde HTML element s ID "sidebar"
    document.getElementById("sidebar").style.width = "0";
}


/**
 * Funkcia openSidebarDetails prepne zobrazenie bočného panelu z filtrov na detaily.
 *
 * Argumenty:
 * Táto funkcia neprijíma žiadne argumenty.
 *
 * Postup:
 * 1. Nájde HTML element s ID "sidebar-filters" a pridá mu triedu "hidden", čím ho skryje.
 * 2. Nájde HTML element s ID "sidebar-details" a odstráni mu triedu "hidden", čím ho zobrazí.
 *
 * Príklad použitia:
 * openSidebarDetails();
 */
function openSidebarDetails() {
    // Skryje element s ID "sidebar-filters" pridaním triedy "hidden"
    document.getElementById("sidebar-filters").classList.add("hidden");
    // Zobrazí element s ID "sidebar-details" odstránením triedy "hidden"
    document.getElementById("sidebar-details").classList.remove("hidden");
}


/**
 * Funkcia closeSidebarDetails prepne zobrazenie bočného panelu z detailov na filtre.
 *
 * Argumenty:
 * Táto funkcia neprijíma žiadne argumenty.
 *
 * Postup:
 * 1. Nájde HTML element s ID "sidebar-filters" a odstráni mu triedu "hidden", čím ho zobrazí.
 * 2. Nájde HTML element s ID "sidebar-details" a pridá mu triedu "hidden", čím ho skryje.
 *
 * Príklad použitia:
 * closeSidebarDetails();
 */
function closeSidebarDetails() {
    // Zobrazí element s ID "sidebar-filters" odstránením triedy "hidden"
    document.getElementById("sidebar-filters").classList.remove("hidden");
    // Skryje element s ID "sidebar-details" pridaním triedy "hidden"
    document.getElementById("sidebar-details").classList.add("hidden");
}


// Pre odstránenie otváracej animácie bočného panelu pri prvom načítaní stránky

openSidebar();

document.addEventListener('DOMContentLoaded', function() {
    // Vyberie element, na ktorý chcete aplikovať prechod
    var element = document.getElementsByClassName('sidebar')[0]; // Nahradí 'yourElementId' skutočným ID vášho elementu

    // Oneskorenie aplikácie CSS prechodu pomocou setTimeout
    setTimeout(function() {
        // Skontroluje, či element existuje, aby sa predišlo chybám
        if (element) {
            // Nastaví vlastnosť CSS pre prechod pomocou style.transition
            element.style.transition = 'all 0.5s ease';
        }
    }, 1000); // 1000 milisekúnd sa rovná 1 sekunde
});
