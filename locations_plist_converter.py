#!/usr/bin/env python3
import sys
import csv
import plistlib
import os
import json
import re
import itertools
import copy

## geostuff
#!/usr/bin/env python3

from geographiclib.constants import Constants
from geographiclib.geodesic import Geodesic


def coordat(f, c1, c2):
    geod = Geodesic(Constants.WGS84_a, Constants.WGS84_f)
    l = geod.InverseLine(c1[1], c1[0], c2[1], c2[0])
    x = (l.s13 * f)
    p = l.Position(x, Geodesic.STANDARD)
    return [p['lon2'], p['lat2']]


def uv(u, v, coords):
    l1 = [coords[0], coords[3]]
    l2 = [coords[1], coords[2]]

    p1 = coordat(u, *l1)
    p2 = coordat(u, *l2)

    x = coordat(v, p1, p2)
    return x

multifloor_regex = r'location_code.(\[[-?0-9]+:[-?0-9]+\]|[0-9]+)'
location_multifloor_regex = r'.+(\[[-?0-9]+:[-?0-9]+\]).+'

def parse_floors(floor_exp):
    m = re.match(r'\[([-?0-9]+):([-?0-9]+)\]', floor_exp)
    if m:
        rgs = m.group(1)
        rge = m.group(2)
        return range(int(rgs), int(rge)+1)
    else:
        return int(floor_exp)

def explode_location_floors(location_map):
    global location_multifloor_regex
    matches = re.match(location_multifloor_regex, location_map['id.code']) 
    if matches:
        key = matches
        floors = parse_floors(key.group(1))
        lms = []
        for floor in floors:
            m = copy.deepcopy(location_map)
            m['id.code'] = location_map['id.code'].replace(key.group(1), str(floor))
            m['id.buildingLevel'] = str(floor)
            lms.append(m)
        return lms
    else:        
        return [location_map]

def explode_floors(location_map):
    global multifloor_regex
    matches = [re.match(multifloor_regex, key) for key in location_map['properties'].keys()] 
    successful = [match for match in matches if match]    
    if successful:
        key = successful[0]
        floors = parse_floors(key.group(1))
        lms = []
        for floor in floors:
            m = copy.deepcopy(location_map)
            m['properties']['location_code'] = location_map['properties'][key.group(0)].replace('%F', str(floor))
            lms.append(m)
        return lms
    else:
        return [location_map]        


def explode_id(location_map):
    if location_map['id.code'] != '':
        location_map['id'] = {
            'code': location_map['id.code'],
            'buildingLevel': int(location_map['id.buildingLevel']),
            'buildingCode': location_map['id.buildingCode']
        }
    return location_map


def explode_routes_ids(route_map):
    if route_map['from.id.code'] != '':
        route_map['from'] = route_map['from.id.code']
        route_map['to'] = route_map['to.id.code']
    return route_map    


def verify(label, map, keys):
    errors = []
    for key in keys:
        if not key in map:
            errors.append("{} missing in {}".format(key, label))
    return errors

locations_file = sys.argv[1]
buildings_file = sys.argv[2]
routes_file = sys.argv[3]
geojson_file = sys.argv[4]
uvlocations_file = sys.argv[5]
uvroutepoints_file = sys.argv[6]

with open(locations_file, 'r', encoding='utf-8-sig') as f:
    locations = list(csv.DictReader(f, delimiter=';'))

locations = [ location for location in locations if not location['id.code'].startswith('#')]
exploded_locations = [explode_location_floors(location) for location in locations]
locations = list(itertools.chain.from_iterable(exploded_locations))
locations = [ explode_id(location) for location in locations ]
locations = [ location for location in locations if location is not None and location['id.code'] != '' ]

locations_map = {}
for location in locations:
    locations_map[location["id"]['code']] = location

with open(buildings_file, 'r', encoding='utf-8-sig') as f:
    buildings = list(csv.DictReader(f, delimiter=';'))
buildings = [ building for building in buildings if building is not None and not building['code'].startswith('#') and building['code'] != '' ]
buildings_map = {}
for building in buildings:
    building['numberOfLevels'] = int(building['numberOfLevels'])
    buildings_map[building['code']] = building

with open(routes_file, 'r', encoding='utf-8-sig') as f:
    routes = list(csv.DictReader(f, delimiter=';'))
routes = [ route for route in routes if route is not None and not route['from.id.code'].startswith('#') and route['from.id.code'] != '' ]
routes = [ explode_routes_ids(route) for route in routes ]

plist_file = os.path.splitext(locations_file)[0] + '.plist'
json_file = os.path.splitext(locations_file)[0] + '.json'


with open(geojson_file, 'r') as f:
    geojson = json.loads(f.read())

fatec_outline = {}
surroundings = {}

exploded_features = [explode_floors(feature) for feature in geojson["features"]]
features = list(itertools.chain.from_iterable(exploded_features))


for feature in features:
    if "kind" in feature["properties"]:
        if feature["properties"]["kind"] == "building_outline":
            building_code = feature["properties"]["building_code"]
            buildings_map[building_code]["outline"] = feature
        elif feature["properties"]["kind"] == "location" or feature["properties"]["kind"] == "route_point":
            location_code = feature["properties"]["location_code"]
            if feature["properties"]["kind"] == "location":
                locations_map[location_code]["point"] = feature
            elif feature["properties"]["kind"] == "route_point":
                locations_map[location_code]["route_point"] = feature
        elif feature["properties"]["kind"] == "building":
            building_code = feature["properties"]["building_code"]
            buildings_map[building_code]["point"] = feature
        elif feature["properties"]["kind"] == "fatec_outline":
            fatec_outline["outline"] = feature
        elif feature["properties"]["kind"] == "fatec":
            fatec_outline["point"] = feature
        elif feature["properties"]["kind"] == "surroundings_outline":
            surroundings["outline"] = feature
        elif feature["properties"]["kind"] == "surroundings":
            surroundings["point"] = feature
    else:
        print("feature {} has no kind".format(feature))

with open(uvlocations_file, 'r', encoding='utf-8') as f:
    uvlocations = list(csv.DictReader(f, delimiter=';'))

uvlocations = [ location for location in uvlocations if not location['id.code'].startswith('#')]
uvlocations = [ location for location in uvlocations if location is not None and location['id.code'] != '' ]


for location in uvlocations:
    l = locations_map[location['id.code']]
    b = buildings_map[l['id.buildingCode']]
    coords = b['outline']['geometry']['coordinates'][0]
    u = float(location['u']) / 100
    v = float(location['v']) / 100
    
    # print(l['point']['geometry']['coordinates'])
    # print(uv(u, v, coords))
    print(l)
    uvcs = uv(u, v, coords)
    l['point'] = {
        'geometry': {
            'coordinates': uvcs,
            'type': 'Point'
        },
        'type': 'Feature',
        'properties': {},
        'id': location['id.code'] + '_point'        
    }
    # l['point']['geometry']['coordinates'] = uv(u, v, coords)
    # location_map[location['id.code']]        


with open(uvroutepoints_file, 'r', encoding='utf-8') as f:
    uvroutes = list(csv.DictReader(f, delimiter=';'))

uvroutes = [ location for location in uvroutes if not location['id.code'].startswith('#')]
uvroutes = [ location for location in uvroutes if location is not None and location['id.code'] != '' ]


for location in uvroutes:
    l = locations_map[location['id.code']]
    b = buildings_map[l['id.buildingCode']]
    coords = b['outline']['geometry']['coordinates'][0]
    u = float(location['u']) / 100
    v = float(location['v']) / 100
    
    # print(l['point']['geometry']['coordinates'])
    # print(uv(u, v, coords))
    print(l)
    uvcs = uv(u, v, coords)
    l['route_point'] = {
        'geometry': {
            'coordinates': uvcs,
            'type': 'Point'
        },
        'type': 'Feature',
        'properties': {},
        'id': location['id.code'] + '_routepoint'
    }
    # l['point']['geometry']['coordinates'] = uv(u, v, coords)
    # location_map[location['id.code']]        


for location in locations:
    if location["type"] == "Access" or location["type"] == "Invisible":
        print(location)
        location["point"] = location["route_point"]

errors = []

for location in locations:
    errors += verify("location {}".format(location["id.code"]), location, ["id", "name", "type", "point", "route_point"])

for building in buildings:
    errors += (verify("building {}".format(building["code"]), building, ["code", "name", "numberOfLevels", "outline", "point"]))

if len(errors) > 0:
    print("Errors: ")
    for error in errors:
        if not len(error) == 0:
            print(error)
    sys.exit(1)

result = {
    'locations': locations,
    'buildings': buildings,
    'routes': routes,
    'fatec': fatec_outline,
    'surroundings': surroundings,
}

# plistlib.writePlist(result, plist_file)
with open(json_file, 'w') as f:
    f.write(json.dumps(result))