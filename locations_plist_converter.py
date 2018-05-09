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

locations_file = sys.argv[1]
buildings_file = sys.argv[2]

with open(locations_file, 'r', encoding='utf-8-sig') as f:
    locations = list(csv.DictReader(f, delimiter=';'))

locations = [ explode_id(location) for location in locations ]
locations = [ location for location in locations if location is not None and location['id.code'] != '' ]

with open(buildings_file, 'r', encoding='utf-8-sig') as f:
    buildings = list(csv.DictReader(f, delimiter=';'))
buildings = [ building for building in buildings if building is not None and building['code'] != '' ]
for building in buildings:
    building['numberOfLevels'] = int(building['numberOfLevels'])

plist_file = os.path.splitext(locations_file)[0] + '.plist'

result = {
    'locations': locations,
    'buildings': buildings
}
plistlib.writePlist(result, plist_file)    