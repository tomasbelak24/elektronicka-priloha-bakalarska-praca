from flask import Flask, render_template, request
import psycopg2
import psycopg2.extras
import os
import folium
from folium.plugins import MarkerCluster
import db_credentials

app = Flask(__name__)

# DB
DB_HOST = os.getenv('DB_HOST', db_credentials.host)
DB_NAME = os.getenv('DB_NAME', db_credentials.dbname)
DB_USER = os.getenv('DB_USER', db_credentials.user)
DB_PASSWORD = os.getenv('DB_PASSWORD', db_credentials.password)

# FUNKCIE

def get_db_connection():

    """
    Funkcia vytvára pripojenie k PostgreSQL databáze pomocou zadaných 
    prihlasovacích údajov a vráti objekt pripojenia.

    Argumenty:
    Táto funkcia nemá žiadne argumenty. Využíva globálne premenné 
    pre konfiguráciu pripojenia k databáze:
      - DB_HOST (str): Názov hostiteľa databázy.
      - DB_NAME (str): Názov databázy.
      - DB_USER (str): Užívateľské meno pre prístup do databázy.
      - DB_PASSWORD (str): Heslo pre prístup do databázy.

    Návratová hodnota:
    psycopg2.extensions.connection: Objekt pripojenia k PostgreSQL databáze.

    Príklad:
    >>> conn = get_db_connection()
    >>> cur = conn.cursor()
    >>> cur.execute("SELECT 1")
    """

    conn = psycopg2.connect(
        host=DB_HOST,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD
    )
    return conn


def query_builder(filters, limit=None):
    """
    Funkcia vytvára SQL dotaz na základe zadaných filtrov a voliteľného limitu.

    Argumenty:
    filters (dict): Slovník, kde kľúče sú názvy stĺpcov a hodnoty sú zoznamy hodnôt, ktoré sa majú filtrovať.
    limit (int, optional): Voliteľný parameter určujúci maximálny počet výsledkov, ktoré majú byť vrátené. Ak nie je zadaný, neaplikuje sa žiadny limit.

    Návratová hodnota:
    str: SQL dotaz ako reťazec, ktorý obsahuje zadané filtre a voliteľný limit.

    Príklad:
    >>> query_builder({'typ': ['futbal', 'basketbal']}, limit=10)
    "select s.id, (case when s.nazov is NULL then '' else s.nazov end) as nazov, u3.nazov as typ, s.x, s.y FROM sportovisko as s LEFT JOIN typyu3 as u3 ON s.typ_sportoviska = u3.id WHERE s.typ_sportoviska IN ( %s ) LIMIT 10"
    """
    
    # Základný SQL dotaz
    base_query = (
        "SELECT s.id, "
        "(CASE WHEN s.nazov IS NULL THEN '' ELSE s.nazov END) AS nazov, "
        "u3.nazov AS typ, s.x, s.y "
        "FROM sportovisko AS s "
        "LEFT JOIN typyu3 AS u3 ON s.typ_sportoviska = u3.id"
    )

    # Ak nie sú zadané žiadne filtre, vráti základný dotaz s voliteľným limitom
    if not filters:
        return base_query if not limit else base_query + f' LIMIT {limit}'
    
    # Pridanie podmienky WHERE pre filtre
    base_query += ' WHERE '
    where_clauses = []
    
    # Vytvorenie podmienok na základe zadaných filtrov
    for column in filters.keys():
        where_clauses.append(f'{column} IN ( %s )')
    where_clauses = ' AND '.join(where_clauses)
    
    # Vrátenie konečného dotazu s voliteľným limitom
    return base_query + where_clauses if not limit else base_query + where_clauses + f' LIMIT {limit}'


def load_nodes(q, params=None):
    """
    Funkcia vykoná SQL dotaz na načítanie športovísk z databázy.

    Argumenty:
    q (str): SQL dotaz, ktorý sa má vykonať.
    params (tuple, optional): Voliteľný parameter, ktorý obsahuje hodnoty, ktoré majú byť použité v SQL dotaze. 
                              Môže byť None, ak nie sú potrebné žiadne parametre.

    Návratová hodnota:
    list: Zoznam uzlov načítaných z databázy. Každý uzol je reprezentovaný ako tuple.

    Príklad:
    >>> load_nodes("SELECT * FROM nodes WHERE type = %s", ('type1',))
    [(1, 'node1', 'type1'), (2, 'node2', 'type1')]
    """
    
    # Získanie pripojenia k databáze
    conn = get_db_connection()
    # Vytvorenie kurzora na vykonanie SQL dotazu
    cur = conn.cursor()
    # Vykonanie dotazu s voliteľnými parametrami
    cur.execute(q, params)
    # Načítanie všetkých výsledkov dotazu
    nodes = cur.fetchall()
    # Zatvorenie kurzora
    cur.close()
    # Zatvorenie pripojenia k databáze
    conn.close()
    # Vrátenie výsledkov ako zoznam uzlov
    return nodes


def load_types():
    """
    Funkcia načíta typy športovísk z databázy a vráti ich ako zoznam.

    Argumenty:
    Táto funkcia nemá žiadne argumenty.

    Návratová hodnota:
    list: Zoznam typov športovísk načítaných z databázy. Každý typ je reprezentovaný ako tuple obsahujúci 
          id, názov a reťazec kombinujúci id a názov.

    Príklad:
    >>> load_types()
    [(1, 'Futbal', '1 - Futbal'), (2, 'Basketbal', '2 - Basketbal')]
    """
    
    # Získanie pripojenia k databáze
    conn = get_db_connection()
    # Vytvorenie kurzora na vykonanie SQL dotazu
    cur = conn.cursor()
    # Vykonanie SQL dotazu na načítanie typov športovísk
    cur.execute("SELECT id, nazov, id::text || ' - ' || nazov FROM typyu3 WHERE id <> 0 ORDER BY id ASC")
    # Načítanie všetkých výsledkov dotazu
    types = cur.fetchall()
    # Zatvorenie kurzora
    cur.close()
    # Zatvorenie pripojenia k databáze
    conn.close()
    # Vrátenie výsledkov ako zoznam typov
    return types


def load_okresy():
    """
    Funkcia načíta okresy z databázy a vráti ich ako zoznam.

    Argumenty:
    Táto funkcia nemá žiadne argumenty.

    Návratová hodnota:
    list: Zoznam okresov načítaných z databázy. Každý okres je reprezentovaný ako tuple obsahujúci id a názov.

    Príklad:
    >>> load_okresy()
    [(1, 'Bratislava'), (2, 'Košice'), (3, 'Prešov')]
    """
    
    # Získanie pripojenia k databáze
    conn = get_db_connection()
    # Vytvorenie kurzora na vykonanie SQL dotazu
    cur = conn.cursor()
    # Vykonanie SQL dotazu na načítanie okresov
    cur.execute("SELECT id, nazov FROM okres ORDER BY id ASC")
    # Načítanie všetkých výsledkov dotazu
    okresy = cur.fetchall()
    # Zatvorenie kurzora
    cur.close()
    # Zatvorenie pripojenia k databáze
    conn.close()
    # Vrátenie výsledkov ako zoznam okresov
    return okresy


# ENDPOINTY

@app.route('/', methods=['GET'])
def index():
    """
    Hlavná funkcia pre obsluhu GET požiadaviek na root URL ('/').
    Načíta údaje o typoch športovísk, okresoch a vytvorí mapu s označením športovísk.

    Argumenty:
    Táto funkcia neprijíma žiadne argumenty priamo, ale využíva parametre GET požiadavky:
      - typeFilter (int): Filter podľa typu športoviska.
      - okresFilter (int): Filter podľa okresu.
      - sportFilter (str): Filter podľa typu športu.

    Návratová hodnota:
    str: Vygenerovaný HTML obsah pre zobrazenie stránky s mapou a filtrami.
    """
    
    # Načítanie typov športovísk a okresov z databázy
    types = load_types()
    okresy = load_okresy()
    
    # Definovanie zoznamu športov
    sporty = ['Futbal', 'Basketbal', 'Volejbal', 'Hokej', 'Tenis', 'Plávanie', 'Viacúčelové']
    sporty_serialized = ["futbal", "basketbal", "volejbal", "hokej", "tenis", "plavanie", "viacucelove"]
    sporty = zip(sporty_serialized, sporty)

    # Inicializácia filtrov z GET parametrov požiadavky
    filters = {}
    filters['u3.id'] = int(request.args.get('typeFilter', -1))
    filters['s.okres_id'] = int(request.args.get('okresFilter', -1))
    sport_filter = request.args.get('sportFilter', 'all')
    if sport_filter != 'all':
        filter_key = f's.{sport_filter}'
        filters[filter_key] = 1
    
    # Odstránenie filtrov, ktoré nie sú nastavené
    filters = {key: value for key, value in filters.items() if value not in ('all', -1,)}
    
    # Vytvorenie SQL dotazu na základe filtrov
    query = query_builder(filters, limit=None)
    print(query, tuple(filters.values()))
    
    # Načítanie športovísk z databázy na základe vytvoreného dotazu
    nodes = load_nodes(query, tuple(filters.values()))

    # Inicializácia mapy s počiatočnými súradnicami
    start_coords = (49.595275, 22.663961)
    folium_map = folium.Map(location=start_coords, zoom_start=8, min_zoom=8, max_bounds=True, min_lon=15.35, max_lon=23.2, min_lat=46.5, max_lat=50.4)

    # Pridanie markerov na mapu pre každé športovisko
    marker_cluster = MarkerCluster().add_to(folium_map)
    for node in nodes:
        id, name, typ, x, y = node
        folium.Marker(
            location=(y, x),
            popup=f'<button class="zisti_viac" onclick="sendNodeIDandOpenSideBar({id})">Viac info</button>',
            tooltip=f'{str(id)} {typ}'
        ).add_to(marker_cluster)

    # Generovanie HTML komponentov mapy
    folium_map.get_root().render()
    header = folium_map.get_root().header.render()
    body = folium_map.get_root().html.render()
    script = folium_map.get_root().script.render()
    
    # Vrátenie vygenerovanej HTML šablóny s mapou a filtrami
    return render_template('index.html', header=header, body=body, script=script, types=types, okresy=okresy, sporty=sporty)


@app.route('/node/<node_id>', methods=['GET'])
def get_node_info(node_id):
    """
    Funkcia načíta informácie o konkrétnom športovisku z databázy na základe poskytnutého ID športoviska.

    Argumenty:
    node_id (str): ID športoviska, pre ktoré sa majú načítať informácie.

    Návratová hodnota:
    list: Zoznam obsahujúci slovník s informáciami o športovisku a zoznam názvov stĺpcov.

    Príklad:
    >>> get_node_info(1)
    [{'názov': 'Športovisko 1', 'Typ športoviska': 'Futbalové ihrisko', ...}, ['názov', 'Typ športoviska', ...]]
    """
    
    # Získanie pripojenia k databáze
    conn = get_db_connection()
    # Vytvorenie kurzora na vykonanie SQL dotazu s možnosťou získať výsledky ako slovník
    cur = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)

    # SQL dotaz na načítanie informácií o konkrétnom športovisku
    q = '''
    SELECT s.nazov AS názov, u3.nazov AS "Typ športoviska", s.status AS status, vl.umiestnenie, 
    v.pristup AS "Prístup", s.d_posledna_uprava AS "Dátum poslednej úpravy (OSM)", vl.povrch, 
    vl.vyska AS "Výška", vl.hlbka AS "Hĺbka", vl.sirka AS "Šírka", vl.dlzka AS "Dĺžka", 
    vy.umele_osvetlenie AS "Umelé osvetlenie", vy.siet AS "Sieť", vy.basketbalove_kose AS "Basketbalové koše",
    v.otvaracie_hodiny AS "Otváracie hodiny", v.poplatok, v.rezervacia AS "Rezervácia", v.sezonnost AS "Sezónnosť",
    b.bezbarierove AS "Bezbariérové", b.bezbarierove_toalety AS "Bezbariérové toalety", sl.pitna_voda AS "Pitná voda", 
    sl.internetove_pripojenie AS "Internetové pripojenie", o.nazov AS obec, ok.nazov AS okres, k.nazov AS kraj, 
    sa.ulica, sa.cislo AS "Číslo", sa.psc AS "PSČ", kk.webstranka AS "Webstránka", kk.email AS "E-mail", 
    kk.telefon AS "Telefón", kk.facebook, kk.instagram, kk.youtube, ad.typ_prevadzkovatela AS "Typ prevádzkovateľa", 
    ad.prevadzkovatel AS "Prevádzkovateľ", ad.majitel AS "Majiteľ", ad.spravovane AS "Spravované", 
    osm.osm_sporty AS "Športy"
    FROM sportovisko s
    LEFT JOIN sportoviskoverejnost v ON s.id = v.id_sportovisko
    LEFT JOIN sportoviskovlastnosti vl ON s.id = vl.id_sportovisko
    LEFT JOIN obec o ON s.obec_id = o.id
    LEFT JOIN okres ok ON s.okres_id = ok.id
    LEFT JOIN kraj k ON s.kraj_id = k.id
    LEFT JOIN sportoviskoadresa sa ON s.id = sa.id_sportovisko
    LEFT JOIN sportoviskobezbarierovost b ON s.id = b.id_sportovisko
    LEFT JOIN sportoviskosluzby sl ON s.id = sl.id_sportovisko
    LEFT JOIN sportoviskoadmin a ON s.id = a.id_sportovisko
    LEFT JOIN sportoviskokontaktneudaje kk ON s.id = kk.id_sportovisko
    LEFT JOIN sportoviskovybavenie vy ON s.id = vy.id_sportovisko
    LEFT JOIN sportoviskoadmin ad ON s.id = ad.id_sportovisko
    LEFT JOIN typyu3 u3 ON u3.id = s.typ_sportoviska
    LEFT JOIN osm_atributy osm ON osm.id_sportovisko = s.id
    WHERE s.id = %s;
    '''
    
    # Vykonanie dotazu s poskytnutým ID športoviska
    cur.execute(q, (node_id,))
    
    # Načítanie výsledku dotazu
    row = cur.fetchone()
    
    # Získanie názvov stĺpcov z výsledku dotazu
    column_names = [desc[0] for desc in cur.description]
    
    # Vytvorenie slovníka s informáciami o športovisku
    output = {}
    for name in column_names:
        output[name] = row[name]
    
    # Zatvorenie kurzora a pripojenia k databáze
    cur.close()
    conn.close()
    #print(output, '|' ,column_names)
    
    # Vrátenie slovníka s informáciami o športovisku a zoznamu názvov stĺpcov
    return [output, column_names]


@app.route('/projekt')
def about():
    """
    Funkcia obsluhuje GET požiadavku na URL '/projekt' a vráti stránku 'about.html'.

    Argumenty:
    Táto funkcia neprijíma žiadne argumenty.

    Návratová hodnota:
    str: HTML obsah stránky 'about.html' vygenerovaný pomocou funkcie render_template.

    Príklad použitia:
    Po otvorení URL '/projekt' v prehliadači sa zobrazí obsah stránky 'about.html'.
    """
    return render_template('about.html')

#@app.route('/test')
#def testing():
#    conn = get_db_connection()
#    cur = conn.cursor()
#    cur.execute("SELECT (case when s.nazov is NULL then '' else s.nazov end) as nazov, u3.nazov as typ, s.x, s.y FROM sportovisko as s LEFT JOIN typyu3 as u3 ON s.typ_sportoviska = u3.id LIMIT 100")
#    test_data = cur.fetchall()
#    cur.close()
#    conn.close()
#    return render_template('testing.html', test_data=test_data)

if __name__ == "__main__":
    app.run(debug=True)