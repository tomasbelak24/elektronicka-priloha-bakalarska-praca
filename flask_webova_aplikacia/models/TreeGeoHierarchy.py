import unidecode

def serialize_name(name):
    """ Serialize the geographic names by removing accents and replacing spaces with underscores. """
    return unidecode.unidecode(name).replace(' ', '_')

def construct_tree(data):
    tree = {}
    for kraj_id, kraj_nazov, okres_id, okres_nazov, obec_id, obec_nazov in data:
        if kraj_id not in tree:
            tree[kraj_id] = {
                'key': kraj_id,
                'label': kraj_nazov,
                'value': serialize_name(kraj_nazov),
                'children': {}
            }

        if okres_id not in tree[kraj_id]['children']:
            tree[kraj_id]['children'][okres_id] = {
                'key': okres_id,
                'label': okres_nazov,
                'value': serialize_name(okres_nazov),
                'children': {}
            }

        tree[kraj_id]['children'][okres_id]['children'][obec_id] = {
            'key': obec_id,
            'label': obec_nazov,
            'value': serialize_name(obec_nazov)
        }

    # Convert nested dictionaries to the required list format
    result = []
    for kraj in tree.values():
        kraj['children'] = [district for district in kraj['children'].values()]
        for district in kraj['children']:
            district['children'] = [municipality for municipality in district['children'].values()]
        result.append(kraj)
    return result