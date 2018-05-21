#!/usr/bin/env python3
import sys
import csv
import plistlib
import os

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

locations_file = sys.argv[1]
buildings_file = sys.argv[2]
routes_file = sys.argv[3]

with open(locations_file, 'r', encoding='utf-8-sig') as f:
    locations = list(csv.DictReader(f, delimiter=';'))

for location in locations:
    print(location)

locations = [ location for location in locations if not location['id.code'].startswith('#')]
locations = [ explode_id(location) for location in locations ]
locations = [ location for location in locations if location is not None and location['id.code'] != '' ]

with open(buildings_file, 'r', encoding='utf-8-sig') as f:
    buildings = list(csv.DictReader(f, delimiter=';'))
buildings = [ building for building in buildings if building is not None and not building['code'].startswith('#') and building['code'] != '' ]
for building in buildings:
    building['numberOfLevels'] = int(building['numberOfLevels'])

with open(routes_file, 'r', encoding='utf-8-sig') as f:
    routes = list(csv.DictReader(f, delimiter=';'))
routes = [ route for route in routes if route is not None and not route['from.id.code'].startswith('#') and route['from.id.code'] != '' ]
routes = [ explode_routes_ids(route) for route in routes ]

plist_file = os.path.splitext(locations_file)[0] + '.plist'

result = {
    'locations': locations,
    'buildings': buildings,
    'routes': routes,
}
plistlib.writePlist(result, plist_file)    