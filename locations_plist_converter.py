#!/usr/bin/env python3
import sys
import csv
import plistlib
import os
import json

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

with open(locations_file, 'r', encoding='utf-8-sig') as f:
    locations = list(csv.DictReader(f, delimiter=';'))

locations = [ location for location in locations if not location['id.code'].startswith('#')]
locations = [ explode_id(location) for location in locations ]
locations = [ location for location in locations if location is not None and location['id.code'] != '' ]

locations_map = {}
for location in locations:
    locations_map[location["id.code"]] = location

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

for feature in geojson["features"]:
    if "kind" in feature["properties"]:
        if feature["properties"]["kind"] == "building_outline":
            building_code = feature["properties"]["building_code"]
            buildings_map[building_code]["outline"] = feature
        elif feature["properties"]["kind"] == "location" or feature["properties"]["kind"] == "route_point":
            location_code = feature["properties"]["location_code"]
            locations_map[location_code]["point"] = feature
        elif feature["properties"]["kind"] == "building":
            building_code = feature["properties"]["building_code"]
            buildings_map[building_code]["point"] = feature
    else:
        print("feature {} has no kind".format(feature))

errors = []

for location in locations:
    errors += verify("location {}".format(location["id.code"]), location, ["id", "name", "type", "point"])

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
}

# plistlib.writePlist(result, plist_file)
with open(json_file, 'w') as f:
    f.write(json.dumps(result))