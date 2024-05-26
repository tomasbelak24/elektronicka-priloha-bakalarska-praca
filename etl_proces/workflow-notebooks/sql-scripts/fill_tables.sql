TRUNCATE typyu1 CASCADE ;
INSERT INTO typyu1 (id, nazov) VALUES (0, 'Nezaradené'),
                                    (1000, 'Vonkajšie športoviská'),
                                    (2000, 'Vnútorné športoviská'),
                                    (3000, 'Vodné športoviská');


INSERT INTO typyu2 (id, nazov, u1_id) VALUES
                                          (0, 'Nezaradené', 0),
                                            (1100, 'Športové ihriská', 1000),
                                            (1200, 'Športové komplexy', 1000),
                                            (1300, 'Nekryté ľadové plochy', 1000),
                                            (2100, 'Haly a telocvične', 2000),
                                            (2200, 'Kryté ľadové plochy', 2000),
                                            (3100, 'Kryté plavecké zariadenia', 3000),
                                            (3200, 'Nekryté plavecké zariadenia', 3000);


INSERT INTO typyu3 (id, nazov, u2_id) VALUES
(0000, 'Nezaradené', 0),
(1110, 'Multifunkčné ihrisko', 1100),
(1120, 'Volejbalové ihrisko', 1100),
(1130, 'Ihrisko na plážový volejbal', 1100),
(1140, 'Futbalové ihrisko', 1100),
(1150, 'Tenisový kurt', 1100),
(1160, 'Basketbalové ihrisko', 1100),
(1170, 'Hokejbalové ihrisko', 1100),
(1180, 'Ihrisko (nešpecifikované)', 1100),
(1190, 'Lúka', 1100),
(1210, 'Futbalový štadión', 1200),
(1220, 'Športový areál', 1200),
(1230, 'Štadión (nešpecifikované)', 1200),
(1310, 'Vonkajšia ľadová plocha', 1300),
(1320, 'Prírodný ľad', 1300),
(2110, 'Športová hala', 2100),
(2120, 'Tenisová hala', 2100),
(2130, 'Basketbalová hala', 2100),
(2140, 'Hokejbalová hala', 2100),
(2150, 'Futbalová hala', 2100),
(2160, 'Volejbalová hala', 2100),
(2170, 'Telocvičňa', 2100),
(2180, 'Športové centrum', 2100),
(2210, 'Zimný štadión', 2200),
(2220, 'Klzisko', 2200),
(2230, 'Hokejová hala', 2200),
(3110, 'Vnútorný bazén', 3100),
(3120, 'Plaváreň', 3100),
(3210, 'Vonkajší bazén', 3200),
(3220, 'Kúpalisko', 3200),
(3230, 'Jazero', 3200),
(3240, 'Pláž / Plavecká oblasť', 3200);

truncate kraj cascade;
INSERT INTO kraj (id, nazov) (select distinct kraj_id, kraj from obec_okres_kraj ORDER BY kraj_id);
INSERT INTO okres (id, nazov, kraj_id) (select distinct okres_id, okres, kraj_id from obec_okres_kraj ORDER BY okres_id);
INSERT INTO obec (id, nazov, okres_id)  (select distinct obec_id, obec, okres_id from obec_okres_kraj ORDER BY obec_id);

TRUNCATE sportovisko CASCADE ;
INSERT INTO Sportovisko (
    id,
    typ_sportoviska,
    nazov,
    status,
    obec_id,
    okres_id,
    kraj_id,
    x,
    y,
    zdroj,
    futbal,
    tenis,
    basketbal,
    hokej,
    volejbal,
    plavanie,
    viacucelove,
    d_posledna_uprava
)

SELECT
    id,
    typ,
    nazov,
    status,
    obec_id,
    okres_id,
    kraj_id,
    ST_X(ST_Centroid(geom)),
    ST_Y(ST_Centroid(geom)),
    zdroj,
    futbal,
    tenis,
    basketbal,
    hokej,
    volejbal,
    plavanie,
    viacucelove,
    naposledy_upravene
FROM sportoviska_source;
SELECT setval('sportovisko_id_seq', (SELECT MAX(id) FROM sportovisko));

--TRUNCATE sportoviskoadresa CASCADE ;
INSERT INTO sportoviskoAdresa (id_sportovisko, psc, ulica, cislo) (SELECT DISTINCT id, "adresa_PSC", adresa_ulica, adresa_cislodomu FROM sportoviska_source WHERE coalesce("adresa_PSC", adresa_ulica, adresa_cislodomu) IS NOT NULL);
--TRUNCATE sportoviskorozmery CASCADE ;
INSERT INTO SportoviskoVlastnosti (id_sportovisko, umiestnenie, povrch, dlzka, sirka, vyska, hlbka)
    (SELECT DISTINCT id, umiestnenie, povrch, dlzka, sirka, vyska, (case when (hlbka is not null) then hlbka
        when (hlbka is null and min_hlbka is not null and max_hlbka is not null) then min_hlbka || ' - ' || max_hlbka
        else coalesce(min_hlbka, max_hlbka)
        end
        ) as hlbka  from sportoviska_source WHERE COALESCE(umiestnenie, povrch, dlzka, sirka, vyska, hlbka, min_hlbka, max_hlbka) IS NOT NULL);
--TRUNCATE sportoviskoverejnost CASCADE ;
INSERT INTO sportoviskoverejnost (id_sportovisko, otvaracie_hodiny, pristup, sezonnost, rezervacia, poplatok) (SELECT DISTINCT id, otvaracie_hodiny, pristup, sezonne, rezervacia, poplatok from sportoviska_source WHERE COALESCE(otvaracie_hodiny, pristup, sezonne, rezervacia, poplatok) IS NOT NULL);
--TRUNCATE sportoviskokontaktneudaje CASCADE ;
INSERT INTO sportoviskokontaktneudaje (id_sportovisko, webstranka, email, telefon, facebook, instagram, youtube) (SELECT DISTINCT id, kontakt_webstranka, kontakt_email, kontakt_telefon, kontakt_facebook, kontakt_instagram, kontakt_youtube FROM sportoviska_source WHERE COALESCE(kontakt_webstranka, kontakt_email, kontakt_telefon, kontakt_facebook, kontakt_instagram, kontakt_youtube) IS NOT NULL);
--TRUNCATE sportoviskoadmin CASCADE ;
INSERT INTO sportoviskoadmin (id_sportovisko, datum_vzniku, spravovane, majitel, prevadzkovatel, typ_prevadzkovatela) (SELECT DISTINCT id, d_zaciatok, pod_dohladom, majitel, prevadzkovatel, typ_prevadzkovatel FROM sportoviska_source WHERE COALESCE(d_zaciatok, pod_dohladom, majitel, prevadzkovatel, typ_prevadzkovatel) IS NOT NULL);
--TRUNCATE sportoviskobezbarierovost CASCADE ;
INSERT INTO sportoviskobezbarierovost (id_sportovisko, bezbarierove, bezbarierove_toalety) (SELECT DISTINCT id, invalid, zachody_invalid FROM sportoviska_source WHERE COALESCE(invalid, zachody_invalid) IS NOT NULL);
--TRUNCATE sportoviskozakladnesluzby CASCADE ;
INSERT INTO sportoviskosluzby (id_sportovisko, pitna_voda, internetove_pripojenie) (SELECT DISTINCT id, pitna_voda, internet_pristup FROM sportoviska_source WHERE COALESCE(pitna_voda, internet_pristup) IS NOT NULL);
--TRUNCATE osm_atributy CASCADE ;
INSERT INTO osm_atributy (id_sportovisko, osm_id, osm_opustene, osm_leisure, osm_leisure1, osm_landuse, osm_zariadenie, osm_budova, osm_prirodne, osm_sporty, osm_zdroj, osm_geometry) (SELECT DISTINCT id, osm_id, opustene, osm_leisure, osm_leisure1, osm_landuse, zariadenie, budova, prirodne, vsetky_sporty_str, zdroj, geom  FROM sportoviska_source);
INSERT INTO sportoviskovybavenie (id_sportovisko, umele_osvetlenie, siet, basketbalove_kose) (SELECT DISTINCT id, umele_osvetlenie, siet, basketbalove_kose from sportoviska_source where coalesce(umele_osvetlenie, siet, basketbalove_kose) is not null);

INSERT INTO vztahmedzisportoviskami (id_sportovisko1, id_sportovisko2, typ_vztahu) (
    SELECT * FROM (
        with help as (
            select s.id, ST_Transform(ST_GeomFromEWKB(osm.osm_geometry), 4326) as geom from sportovisko s
            join osm_atributy osm on s.id = osm.id_sportovisko
        )
        select a.id, b.id, 'sportovisko_obsahuje_sportovisko' as rel_typ from help a
            join help b
            on ST_Contains(a.geom, b.geom) and a.id != b.id
                )
);

DROP TABLE IF EXISTS  sportoviska_source;
DROP TABLE IF EXISTS obec_okres_kraj;