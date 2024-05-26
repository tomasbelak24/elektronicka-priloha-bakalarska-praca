CREATE EXTENSION IF NOT EXISTS postgis;
DROP TABLE IF EXISTS VztahMedziSportoviskami CASCADE ;
DROP TABLE IF EXISTS OSM_atributy CASCADE ;
DROP TABLE IF EXISTS SportoviskoKontaktneUdaje CASCADE ;
DROP TABLE IF EXISTS SportoviskoZakladneSluzby CASCADE ;
DROP TABLE IF EXISTS SportoviskoBezbarierovost CASCADE ;
DROP TABLE IF EXISTS SportoviskoAdmin CASCADE ;
DROP TABLE IF EXISTS SportoviskoVlastnosti CASCADE ;
DROP TABLE IF EXISTS SportoviskoVerejnost CASCADE ;
DROP TABLE IF EXISTS SportoviskoAdresa CASCADE ;
DROP TABLE IF EXISTS SportoviskoVybavenie CASCADE ;
DROP TABLE IF EXISTS SportoviskoSluzby CASCADE ;
DROP TABLE IF EXISTS TypyU3 CASCADE ;
DROP TABLE IF EXISTS TypyU2 CASCADE ;
DROP TABLE IF EXISTS TypyU1 CASCADE ;
DROP TABLE IF EXISTS Sportovisko CASCADE ;
DROP TABLE IF EXISTS Obec CASCADE ;
DROP TABLE IF EXISTS Okres CASCADE ;
DROP TABLE IF EXISTS Kraj CASCADE ;

-- TABULKA KRAJ
    CREATE TABLE Kraj (
        id SERIAL PRIMARY KEY,
        nazov VARCHAR(255)
    );

-- TABULKA OKRES
    CREATE TABLE Okres (
        id SERIAL PRIMARY KEY,
        nazov VARCHAR(255),
        kraj_id INT,
        FOREIGN KEY (kraj_id) REFERENCES kraj(id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );

-- TABULKA OBEC
    CREATE TABLE Obec (
        id SERIAL PRIMARY KEY,
        nazov VARCHAR(255),
        okres_id INT,
        --geometry GEOMETRY(Geometry, 4326),
        --centroid_x DOUBLE PRECISION NOT NULL,
        --centroid_y DOUBLE PRECISION NOT NULL,
        FOREIGN KEY (okres_id) REFERENCES okres(id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );

-- Tabulka TYPY_u1 (outdoor, indoor, vodne)

    CREATE TABLE TypyU1 (
        id INT PRIMARY KEY NOT NULL,
        nazov VARCHAR(255)
    );

-- Tablka TYPY_u2 (v ramci kazdej u1 detailnejsie typy)
    CREATE TABLE TypyU2 (
        id INT PRIMARY KEY NOT NULL,
        nazov VARCHAR(255),
        u1_id INT,
        FOREIGN KEY (u1_id) REFERENCES TypyU1(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);


-- Tabulka typy_u3 (v ramci kazdej u2 detailne typy sportovisk)
-- 0 bude nezaradene ihrisko
    CREATE TABLE TypyU3 (
        id INT PRIMARY KEY NOT NULL,
        nazov VARCHAR(255),
        u2_id INT,
        FOREIGN KEY (u2_id) REFERENCES TypyU2(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE
);

-- TABULKA SPORTOVISKA
    CREATE TABLE Sportovisko (
        id SERIAL PRIMARY KEY,
        typ_sportoviska INT NOT NULL DEFAULT 0,
        nazov VARCHAR(255),
        status VARCHAR(10),
        obec_id INT NOT NULL,
        okres_id INT NOT NULL,
        kraj_id INT NOT NULL,
        x DOUBLE PRECISION NOT NULL,
        y DOUBLE PRECISION NOT NULL,
        zdroj VARCHAR(255),
        futbal INT NOT NULL,
        tenis INT NOT NULL,
        basketbal INT NOT NULL,
        hokej INT NOT NULL,
        volejbal INT NOT NULL,
        plavanie INT NOT NULL,
        viacucelove INT NOT NULL,
        --specificke_vlastnosti_podla_typu JSON,
        --viac_informacii TEXT,
        d_posledna_uprava TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (typ_sportoviska) REFERENCES TypyU3(id)
                ON DELETE SET DEFAULT
                ON UPDATE CASCADE,
        FOREIGN KEY (obec_id) REFERENCES obec(id)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE,
        FOREIGN KEY (okres_id) REFERENCES okres(id)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE,
        FOREIGN KEY (kraj_id) REFERENCES kraj(id)
                             ON DELETE CASCADE
                             ON UPDATE CASCADE
    );

-- TABULKA S ADRESOU

    CREATE TABLE SportoviskoAdresa (
        id_sportovisko INT PRIMARY KEY,
        psc VARCHAR(20),
        ulica VARCHAR(255),
        cislo VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );


-- TABULKA S INFO O SPORTOVISKU
    CREATE TABLE SportoviskoVlastnosti(
        id_sportovisko INT PRIMARY KEY,
        umiestnenie VARCHAR(255),
        povrch VARCHAR(255),
        vyska VARCHAR(255),
        hlbka VARCHAR(255),
        sirka VARCHAR(255),
        dlzka VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );

-- TABULKA S INFO O VYBAVENI
    CREATE TABLE SportoviskoVybavenie(
        id_sportovisko INT PRIMARY KEY,
        umele_osvetlenie VARCHAR(255),
        siet VARCHAR(255),
        basketbalove_kose VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );




-- TABULKA S INFO PRE VEREJNOST
    CREATE TABLE SportoviskoVerejnost(
        id_sportovisko INT PRIMARY KEY,
        otvaracie_hodiny VARCHAR(255),
        pristup VARCHAR(255),
        sezonnost VARCHAR(255),
        rezervacia VARCHAR(255),
        poplatok VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );

-- TABULKA S KONTAKTNYMI INFORMACIAMI
    CREATE TABLE SportoviskoKontaktneUdaje(
        id_sportovisko INT PRIMARY KEY,
        webstranka VARCHAR(255),
        email VARCHAR(255),
        telefon VARCHAR(255),
        facebook VARCHAR(255),
        instagram VARCHAR(255),
        youtube VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );



-- TABULKA S ADMINISTRATIVNYMI VECAMI
    CREATE TABLE SportoviskoAdmin(
        id_sportovisko INT PRIMARY KEY,
        datum_vzniku VARCHAR(255), -- vedene ako varchar kvoli nejednotnemu formatu datumov v OSM
        spravovane VARCHAR(3),
        majitel VARCHAR(255),
        prevadzkovatel VARCHAR(255),
        typ_prevadzkovatela VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );


-- TABULKA S INFORMACIAMI OHLADOM BEZBARIEROVOSTI
    CREATE TABLE SportoviskoBezbarierovost(
        id_sportovisko INT PRIMARY KEY,
        bezbarierove VARCHAR(255),
        bezbarierove_toalety VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );


-- TABULKA S INFORMACIAMI OHLADOM ZAKLADNYCH SLUZIEB
    CREATE TABLE SportoviskoSluzby(
        id_sportovisko INT PRIMARY KEY,
        pitna_voda VARCHAR(255),
        internetove_pripojenie VARCHAR(255),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
    );


-- TABULKA OSM_ATRIBUTY
    CREATE TABLE OSM_atributy(
        id_sportovisko INT PRIMARY KEY,
        osm_id VARCHAR(255) NOT NULL,
        osm_opustene varchar(3),
        osm_leisure VARCHAR(255),
        osm_leisure1 VARCHAR(255),
        osm_landuse VARCHAR(255),
        osm_zariadenie VARCHAR(255),
        osm_budova VARCHAR(255),
        osm_prirodne VARCHAR(255),
        osm_sporty VARCHAR(255),
        osm_zdroj VARCHAR(255),
        osm_geometry GEOMETRY(Geometry, 4326),
        FOREIGN KEY (id_sportovisko) REFERENCES sportovisko(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        UNIQUE(osm_id)
    );


-- TABULKA vztah_medzi_sportoviskami
    CREATE TABLE VztahMedziSportoviskami (
        id_sportovisko1 INT NOT NULL,
        id_sportovisko2 INT NOT NULL,
        typ_vztahu VARCHAR(255),
        FOREIGN KEY (id_sportovisko1) REFERENCES sportovisko(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        FOREIGN KEY (id_sportovisko2) REFERENCES sportovisko(id)
            ON DELETE CASCADE
            ON UPDATE CASCADE,
        PRIMARY KEY (id_sportovisko1, id_sportovisko2),
        CHECK (id_sportovisko1 <> id_sportovisko2)
    );


-- Popis tabulky Kraj
COMMENT ON TABLE Kraj IS 'Tabuľka ukladá informácie o krajoch.';
COMMENT ON COLUMN Kraj.id IS 'Jedinečný identifikátor kraja.';
COMMENT ON COLUMN Kraj.nazov IS 'Názov kraja.';

-- Popis tabulky Okres
COMMENT ON TABLE Okres IS 'Tabuľka ukladá informácie o okresoch.';
COMMENT ON COLUMN Okres.id IS 'Jedinečný identifikátor okresu.';
COMMENT ON COLUMN Okres.nazov IS 'Názov okresu.';
COMMENT ON COLUMN Okres.kraj_id IS 'Identifikátor kraja, ku ktorému okres patrí.';

-- Popis tabulky Obec
COMMENT ON TABLE Obec IS 'Tabuľka ukladá informácie o obciach.';
COMMENT ON COLUMN Obec.id IS 'Jedinečný identifikátor obce.';
COMMENT ON COLUMN Obec.nazov IS 'Názov obce.';
COMMENT ON COLUMN Obec.okres_id IS 'Identifikátor okresu, ku ktorému obec patrí.';

-- Popis tabulky TypyU1
COMMENT ON TABLE TypyU1 IS 'Tabuľka ukladá informácie o typoch U1 (outdoor, indoor, vodné).';
COMMENT ON COLUMN TypyU1.id IS 'Jedinečný identifikátor typu U1.';
COMMENT ON COLUMN TypyU1.nazov IS 'Názov typu U1.';

-- Popis tabulky TypyU2
COMMENT ON TABLE TypyU2 IS 'Tabuľka ukladá informácie o typoch U2 (detaily v rámci U1).';
COMMENT ON COLUMN TypyU2.id IS 'Jedinečný identifikátor typu U2.';
COMMENT ON COLUMN TypyU2.nazov IS 'Názov typu U2.';
COMMENT ON COLUMN TypyU2.u1_id IS 'Identifikátor typu U1, ku ktorému typ U2 patrí.';

-- Popis tabulky TypyU3
COMMENT ON TABLE TypyU3 IS 'Tabuľka ukladá informácie o typoch U3 (detaily športovísk).';
COMMENT ON COLUMN TypyU3.id IS 'Jedinečný identifikátor typu U3.';
COMMENT ON COLUMN TypyU3.nazov IS 'Názov typu U3.';
COMMENT ON COLUMN TypyU3.u2_id IS 'Identifikátor typu U2, ku ktorému typ U3 patrí.';

-- Popis tabulky Sportovisko
COMMENT ON TABLE Sportovisko IS 'Tabuľka ukladá informácie o športoviskách.';
COMMENT ON COLUMN Sportovisko.id IS 'Jedinečný identifikátor športoviska.';
COMMENT ON COLUMN Sportovisko.typ_sportoviska IS 'Typ športoviska podľa typu U3.';
COMMENT ON COLUMN Sportovisko.nazov IS 'Názov športoviska.';
COMMENT ON COLUMN Sportovisko.status IS 'Status športoviska. Reprezentuje či je športovisko aktívne alebo neaktívne (opustené).';
COMMENT ON COLUMN Sportovisko.obec_id IS 'Identifikátor obce, v ktorej sa športovisko nachádza.';
COMMENT ON COLUMN Sportovisko.okres_id IS 'Identifikátor okresu, v ktorom sa športovisko nachádza.';
COMMENT ON COLUMN Sportovisko.kraj_id IS 'Identifikátor kraja, v ktorom sa športovisko nachádza.';
COMMENT ON COLUMN Sportovisko.x IS 'X súradnica polohy športoviska.';
COMMENT ON COLUMN Sportovisko.y IS 'Y súradnica polohy športoviska.';
COMMENT ON COLUMN Sportovisko.zdroj IS 'Zdroj informácií o športovisku (Vždy OpenStreetMap).';
COMMENT ON COLUMN Sportovisko.futbal IS 'Indikátor, či je na športovisku možné hrať futbal.';
COMMENT ON COLUMN Sportovisko.tenis IS 'Indikátor, či je na športovisku možné hrať tenis.';
COMMENT ON COLUMN Sportovisko.basketbal IS 'Indikátor, či je na športovisku možné hrať basketbal.';
COMMENT ON COLUMN Sportovisko.hokej IS 'Indikátor, či je na športovisku možné hrať hokej.';
COMMENT ON COLUMN Sportovisko.volejbal IS 'Indikátor, či je na športovisku možné hrať volejbal.';
COMMENT ON COLUMN Sportovisko.plavanie IS 'Indikátor, či je na športovisku možné plávať.';
COMMENT ON COLUMN Sportovisko.viacucelove IS 'Indikátor, či je športovisko viacúčelové.';
COMMENT ON COLUMN Sportovisko.d_posledna_uprava IS 'Dátum poslednej úpravy informácií o športoviskuv v OpenStreetMap.';

-- Popis tabulky SportoviskoAdresa
COMMENT ON TABLE SportoviskoAdresa IS 'Tabuľka ukladá adresu športoviska.';
COMMENT ON COLUMN SportoviskoAdresa.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoAdresa.psc IS 'Poštové smerovacie číslo športoviska.';
COMMENT ON COLUMN SportoviskoAdresa.ulica IS 'Ulica, kde sa športovisko nachádza.';
COMMENT ON COLUMN SportoviskoAdresa.cislo IS 'Orientačné číslo športoviska.';

-- Popis tabulky SportoviskoVlastnosti
COMMENT ON TABLE SportoviskoVlastnosti IS 'Tabuľka ukladá vlastnosti športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.umiestnenie IS 'Umiestnenie športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.povrch IS 'Povrch športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.vyska IS 'Výška športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.hlbka IS 'Hĺbka športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.sirka IS 'Šírka športoviska.';
COMMENT ON COLUMN SportoviskoVlastnosti.dlzka IS 'Dĺžka športoviska.';

-- Popis tabulky SportoviskoVybavenie
COMMENT ON TABLE SportoviskoVybavenie IS 'Tabuľka ukladá informácie o vybavení športoviska.';
COMMENT ON COLUMN SportoviskoVybavenie.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoVybavenie.umele_osvetlenie IS 'Indikátor, či má športovisko umelé osvetlenie.';
COMMENT ON COLUMN SportoviskoVybavenie.siet IS 'Indikátor, či má športovisko sieť (môže byť ľubovoľná sieť - tenis, volejbal, plážový volejbal).';
COMMENT ON COLUMN SportoviskoVybavenie.basketbalove_kose IS 'Indikátor, či má športovisko basketbalové koše, prípadne koľko.';

-- Popis tabulky SportoviskoVerejnost
COMMENT ON TABLE SportoviskoVerejnost IS 'Tabuľka ukladá informácie o prístupe verejnosti k športovisku.';
COMMENT ON COLUMN SportoviskoVerejnost.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoVerejnost.otvaracie_hodiny IS 'Otváracie hodiny športoviska.';
COMMENT ON COLUMN SportoviskoVerejnost.pristup IS 'Prístup k športovisku.';
COMMENT ON COLUMN SportoviskoVerejnost.sezonnost IS 'Sezónnosť športoviska.';
COMMENT ON COLUMN SportoviskoVerejnost.rezervacia IS 'Informácia o nutnosti rezervácie športoviska.';
COMMENT ON COLUMN SportoviskoVerejnost.poplatok IS 'Informácia o poplatku za používanie športoviska.';

-- Popis tabulky SportoviskoKontaktneUdaje
COMMENT ON TABLE SportoviskoKontaktneUdaje IS 'Tabuľka ukladá kontaktné údaje športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.webstranka IS 'Webstránka športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.email IS 'Email športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.telefon IS 'Telefónne číslo športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.facebook IS 'Facebook stránka športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.instagram IS 'Instagram účet športoviska.';
COMMENT ON COLUMN SportoviskoKontaktneUdaje.youtube IS 'YouTube kanál športoviska.';

-- Popis tabulky SportoviskoAdmin
COMMENT ON TABLE SportoviskoAdmin IS 'Tabuľka ukladá administratívne informácie o športovisku.';
COMMENT ON COLUMN SportoviskoAdmin.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoAdmin.datum_vzniku IS 'Dátum vzniku športoviska.';
COMMENT ON COLUMN SportoviskoAdmin.spravovane IS 'Informácia o tom, či je športovisko spravované.';
COMMENT ON COLUMN SportoviskoAdmin.majitel IS 'Majiteľ športoviska.';
COMMENT ON COLUMN SportoviskoAdmin.prevadzkovatel IS 'Prevádzkovateľ športoviska.';
COMMENT ON COLUMN SportoviskoAdmin.typ_prevadzkovatela IS 'Typ prevádzkovateľa športoviska.';

-- Popis tabulky SportoviskoBezbarierovost
COMMENT ON TABLE SportoviskoBezbarierovost IS 'Tabuľka ukladá informácie o bezbariérovosti športoviska.';
COMMENT ON COLUMN SportoviskoBezbarierovost.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoBezbarierovost.bezbarierove IS 'Indikátor, či je športovisko bezbariérové.';
COMMENT ON COLUMN SportoviskoBezbarierovost.bezbarierove_toalety IS 'Indikátor, či má športovisko bezbariérové toalety.';

-- Popis tabulky SportoviskoSluzby
COMMENT ON TABLE SportoviskoSluzby IS 'Tabuľka ukladá informácie o základných službách športoviska.';
COMMENT ON COLUMN SportoviskoSluzby.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN SportoviskoSluzby.pitna_voda IS 'Informácia o dostupnosti pitnej vody na športovisku.';
COMMENT ON COLUMN SportoviskoSluzby.internetove_pripojenie IS 'Informácia o dostupnosti internetového pripojenia na športovisku.';

-- Popis tabulky OSM_atributy
COMMENT ON TABLE OSM_atributy IS 'Tabuľka ukladá OSM atribúty športoviska.';
COMMENT ON COLUMN OSM_atributy.id_sportovisko IS 'Identifikátor športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_id IS 'Jedinečný OSM identifikátor športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_opustene IS 'Indikátor, či je športovisko opustené.';
COMMENT ON COLUMN OSM_atributy.osm_leisure IS 'OSM leisure atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_leisure1 IS 'OSM leisure1 atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_landuse IS 'OSM landuse atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_zariadenie IS 'OSM zariadenie atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_budova IS 'OSM budova atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_prirodne IS 'OSM prírodné atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_sporty IS 'OSM športy atribút športoviska.';
COMMENT ON COLUMN OSM_atributy.osm_zdroj IS 'Zdroj OSM informácií o športovisku.';
COMMENT ON COLUMN OSM_atributy.osm_geometry IS 'Geometria OSM športoviska.';

-- Popis tabulky VztahMedziSportoviskami
COMMENT ON TABLE VztahMedziSportoviskami IS 'Tabuľka ukladá informácie o topologických vzťahoch medzi geometriami športovísk.';
COMMENT ON COLUMN VztahMedziSportoviskami.id_sportovisko1 IS 'Identifikátor prvého športoviska.';
COMMENT ON COLUMN VztahMedziSportoviskami.id_sportovisko2 IS 'Identifikátor druhého športoviska.';
COMMENT ON COLUMN VztahMedziSportoviskami.typ_vztahu IS 'Typ vzťahu medzi športoviskami.';
