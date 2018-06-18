//
//  PointOfInterestFeatures.swift
//  Fateconde
//
//  Created by André Roque Matheus on 28/05/2018.
//  Copyright © 2018 André Roque Matheus. All rights reserved.
//

import Foundation
import Mapbox
import PointOfInterest

protocol MappingLayer {
    func install(style: MGLStyle)
    func show()
    func hide()
}

struct ZoomableInfo<T> {
    private let byLevel: [MapZoomLevel: T]
    let defaultValue: T
    
    init(_ values: [MapZoomLevel: T], defaultValue: T) {
        byLevel = values
        self.defaultValue = defaultValue
    }
    
    init(defaultValue: T) {
        byLevel = [:]
        self.defaultValue = defaultValue
    }
    
    func forLevel(_ level: MapZoomLevel) -> T {
        if let t = byLevel[level] {
            return t
        } else {
            return defaultValue
        }
    }
    
    func map<R>(_ transform: (T) -> R) -> ZoomableInfo<R> {
        let transformed: [MapZoomLevel: R] = self.byLevel.mapValues(transform)
        return ZoomableInfo<R>(transformed, defaultValue: transform(self.defaultValue))
    }
    
    var nsExpression: NSExpression {
        if byLevel.isEmpty {
            return NSExpression(forConstantValue: self.defaultValue)
        } else {
            var byLevel = self.byLevel
            for zoom in MapZoomLevel.allValues {
                if !byLevel.keys.contains(zoom) {
                    byLevel[zoom] = defaultValue
                }
            }
            let byZoomDouble = Dictionary.init(uniqueKeysWithValues: byLevel.map {(key, value) in
                return (key.rawValue, value)
            })
            return NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                byZoomDouble)
        }
    }
}

struct ImageLayer: MappingLayer {
    let identifier: String
    let image: UIImage
    let source: MGLImageSource
    let layer: MGLRasterStyleLayer
    let attributes: ImageLayerAttributes
    
    init(identifier: String, polygon: QuadPolygon, image: UIImage, attributes: ImageLayerAttributes) {
        self.image = image
        let quad = polygon.mglCoordinateQuad
        self.identifier = identifier
        self.attributes = attributes
        source = MGLImageSource(identifier: "fatec-\(identifier)-image-source", coordinateQuad: quad, image: image)
        layer = MGLRasterStyleLayer(identifier: "fatec-\(identifier)-image-layer", source: source)
        attributes.applyTo(layer)
    }
    
    func install(style: MGLStyle) {
        style.addSource(source)
        if let annotationsLayer = style.layer(withIdentifier: "com.mapbox.annotations.points") {
            style.insertLayer(layer, below: annotationsLayer)
        } else {
            style.addLayer(layer)
        }
    }
    
    func show() {
        layer.isVisible = true
    }
    
    func hide() {
        layer.isVisible = false
    }
}

struct LineLayer: MappingLayer {
    let identifier: String
    let source: MGLShapeSource
    let strokeLayer: MGLLineStyleLayer
    let strokeAttributes: LineLayerAttributes
    let feature: MGLPolylineFeature
    
    init(identifier: String, coordinates: [CLLocationCoordinate2D], strokeAttributes: LineLayerAttributes) {
        self.identifier = identifier
        self.feature = MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
        let features = [feature]
        self.source = MGLShapeSource(identifier: "\(identifier)-line-source", features: features, options: nil)
        self.strokeLayer = MGLLineStyleLayer(identifier: "\(identifier)-line-stroke", source: source)
        self.strokeAttributes = strokeAttributes
        self.strokeAttributes.applyTo(strokeLayer)
    }
    
    func install(style: MGLStyle) {
        style.addSource(source)
        style.addLayer(strokeLayer)
    }
    
    func uninstall(style: MGLStyle) {
        style.removeLayer(strokeLayer)
        style.removeSource(source)
    }
    
    func show() {
        strokeLayer.isVisible = true
    }
    
    func hide() {
        strokeLayer.isVisible = false
    }
}

struct CirclesLayer: MappingLayer {
    let identifier: String
    let source: MGLShapeSource
    let circlesLayer: MGLCircleStyleLayer
    let circleAttributes: CircleLayerAttributes
    let features: [MGLPointFeature]
    
    init(identifier: String, coordinates: [CLLocationCoordinate2D], circleAttributes: CircleLayerAttributes) {
        self.identifier = identifier
        var features: [MGLPointFeature] = []
        for coord in coordinates {
            let feature = MGLPointFeature()
            feature.coordinate = coord
            features.append(feature)
        }
        self.features = features
        self.source = MGLShapeSource(identifier: "\(identifier)-circles-source", features: features, options: nil)
        self.circlesLayer = MGLCircleStyleLayer(identifier: "\(identifier)-circles-layer", source: source)
        circleAttributes.applyTo(self.circlesLayer)
        self.circleAttributes = circleAttributes
    }
    
    func install(style: MGLStyle) {
        style.addSource(self.source)
        style.addLayer(self.circlesLayer)
    }
    
    func uninstall(style: MGLStyle) {
        style.removeLayer(self.circlesLayer)
        style.removeSource(self.source)
    }
    
    func show() {
        self.circlesLayer.isVisible = true
    }
    
    func hide() {
        self.circlesLayer.isVisible = false
    }

}

struct OutlineLayer: MappingLayer {
    let identifier: String
    let source: MGLShapeSource
    let strokeLayer: MGLLineStyleLayer
    let fillLayer: MGLFillStyleLayer
    let strokeAttributes: LineLayerAttributes
    let fillAttributes: FillLayerAttributes
    let feature: MGLPolygonFeature
    
    init(identifier: String, coordinates: [CLLocationCoordinate2D],
         strokeAttributes: LineLayerAttributes, fillAttributes: FillLayerAttributes) {
        self.identifier = identifier
        self.feature = MGLPolygonFeature(coordinates: coordinates, count: UInt(coordinates.count))
        let features = [feature]
        self.source = MGLShapeSource(identifier: "\(identifier)-outline-source", features: features, options: nil)
        self.strokeLayer = MGLLineStyleLayer(identifier: "\(identifier)-outline-stroke", source: source)
        self.fillLayer = MGLFillStyleLayer(identifier: "\(identifier)-outline-fill", source: source)
        self.strokeAttributes = strokeAttributes
        self.fillAttributes = fillAttributes
        self.strokeAttributes.applyTo(strokeLayer)
        self.fillAttributes.applyTo(fillLayer)
    }
    func install(style: MGLStyle) {
        style.addSource(source)
        style.addLayer(fillLayer)
        style.addLayer(strokeLayer)
    }
    
    func show() {
        strokeLayer.isVisible = true
        fillLayer.isVisible = true
    }
    
    func hide() {
        strokeLayer.isVisible = false
        fillLayer.isVisible = false
    }

}

struct NameLayer: MappingLayer {
    let identifier: String
    let text: String
    let source: MGLShapeSource
    let pointFeature: MGLPointFeature
    let symbolLayer: MGLSymbolStyleLayer
    let attributes: SymbolTextLayerAttributes
    
    init(identifier: String, coordinate: CLLocationCoordinate2D, text: String, attributes: SymbolTextLayerAttributes) {
        self.identifier = identifier
        self.text = text
        pointFeature = MGLPointFeature()
        pointFeature.identifier = "fatec-feature-\(identifier)"
        pointFeature.coordinate = coordinate
        pointFeature.attributes = [
            "name": text
        ]
        let features = [pointFeature]
        source = MGLShapeSource(identifier: "fatec-\(identifier)-name", features: features, options: nil)
        symbolLayer = MGLSymbolStyleLayer(identifier: "fatec-\(identifier)-name-layer", source: source)
        symbolLayer.text = NSExpression(forConstantValue: text)
        self.attributes = attributes
        attributes.applyTo(symbolLayer)
    }

    func install(style: MGLStyle) {
        style.addSource(source)
        style.addLayer(symbolLayer)
    }
    
    func show() {
        symbolLayer.isVisible = true
    }
    
    func hide() {
        symbolLayer.isVisible = false
    }
}

struct LineLayerAttributes {
    let lineColor: UIColor
    let lineWidth: ZoomableInfo<Double>
    let visibility: ZoomableInfo<Double>
    
    func applyTo(_ layer: MGLLineStyleLayer) {
        layer.lineColor = NSExpression(forConstantValue: lineColor)
        layer.lineWidth = lineWidth.nsExpression
        layer.lineOpacity = visibility.nsExpression
    }
}

struct FillLayerAttributes {
    let fillColor: UIColor
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLFillStyleLayer) {
        layer.fillColor = NSExpression(forConstantValue: fillColor)
        layer.fillOpacity = visibility.map(boolToVisibility).nsExpression
    }
}

func boolToVisibility(_ bool: Bool) -> Double {
    if bool {
        return 1.0
    } else {
        return 0.0
    }
}

struct Halo {
    let width: ZoomableInfo<Double>
    let color: UIColor
    let blurWidth: ZoomableInfo<Double>
}

struct SymbolTextLayerAttributes {
    let textSize: ZoomableInfo<Double>
    let visibility: ZoomableInfo<Bool>
    let textBlur: Halo?
    
    func applyTo(_ layer: MGLSymbolStyleLayer) {
        layer.textAllowsOverlap = NSExpression(forConstantValue: true)
        layer.textFontSize = textSize.nsExpression
        layer.textOpacity = visibility.map(boolToVisibility).nsExpression
        if let halo = textBlur {
            layer.textHaloBlur = halo.width.nsExpression
            layer.textHaloColor = NSExpression.init(forConstantValue: halo.color)
            layer.textHaloWidth = halo.blurWidth.nsExpression
        }
    }
}

struct ImageLayerAttributes {
    let visibility: ZoomableInfo<Bool>
    
    func applyTo(_ layer: MGLRasterStyleLayer) {
        layer.rasterOpacity = visibility.map(boolToVisibility).nsExpression
    }
}

struct CircleLayerAttributes {
    let circleColor: UIColor
    let circleRadius: ZoomableInfo<Double>
    let opacity: Double
    
    func applyTo(_ layer: MGLCircleStyleLayer) {
        layer.circleColor = NSExpression(forConstantValue:  self.circleColor)
        layer.circleRadius = self.circleRadius.nsExpression
        layer.circleOpacity = NSExpression(forConstantValue: self.opacity)
    }
}

class FatecMapHelper {
    let identifier = "fatec"
    let fatec: Fatec
    let outlineLayer: MappingLayer
    let imageLayer: MappingLayer
    let nameLayer: MappingLayer
    let zoomLevel = 16.75
    let stroke = LineLayerAttributes(lineColor: FatecColors.cinzaEscuro,
                                     lineWidth: ZoomableInfo<Double>([:], defaultValue: 1.0),
                                     visibility: ZoomableInfo(defaultValue: 1.0))
    let fill = FillLayerAttributes(fillColor: FatecColors.branco,
                                   visibility: ZoomableInfo<Bool>(defaultValue: true))
    
    init(fatec: Fatec) {
        self.fatec = fatec
        self.outlineLayer = OutlineLayer(identifier: identifier, coordinates: fatec.quadPolygon.coordinates, strokeAttributes: stroke, fillAttributes: fill)
        
        if let fatecPlanImage = UIImage(named: fatec.planImageKey) {
            self.imageLayer = ImageLayer(identifier: identifier, polygon: fatec.quadPolygon, image: fatecPlanImage,
                                           attributes: ImageLayerAttributes(visibility: ZoomableInfo<Bool>([MapZoomLevel.Fatec: true], defaultValue: false)))
        } else {
            self.imageLayer = self.outlineLayer
        }
        
        self.nameLayer = NameLayer(identifier: identifier, coordinate: fatec.point, text: "FATEC",
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 12.0),
                                                                         visibility: ZoomableInfo<Bool>([MapZoomLevel.Surroundings: true], defaultValue: false),
                                                                         textBlur: Halo(width: ZoomableInfo.init(defaultValue: 0.1), color: UIColor.white, blurWidth: ZoomableInfo.init(defaultValue: 10.0))))
    }
}

class SurroundingsHelper {
    let zoomLevel = 15.0

}

class BuildingMapHelper {
    let identifier: String
    let building: Building
    let outlineLayer: MappingLayer
    let planLayers: [Int: MappingLayer]
    let nameLayer: MappingLayer
    let stroke = LineLayerAttributes(lineColor: FatecColors.cinzaEscuro,
                                     lineWidth: ZoomableInfo<Double>([:], defaultValue: 1.0),
                                     visibility: ZoomableInfo<Double>([.Surroundings: 0.0], defaultValue: 1.0))
    
    init(building: Building) {
        self.building = building
        self.identifier = "building-\(building.code)"
        // TODO: use short name
        self.nameLayer = NameLayer(identifier: identifier, coordinate: building.point, text: building.name,
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 9.0), visibility: ZoomableInfo<Bool>([MapZoomLevel.Fatec: true], defaultValue: false),
                                                                         textBlur: Halo(width: ZoomableInfo.init(defaultValue: 0.1), color: UIColor.white, blurWidth: ZoomableInfo.init(defaultValue: 10.0))))
        // TODO: play layers by floor
        var planLayers: [Int: MappingLayer] = [:]
        for level in self.building.levels {
            let imageKey = "\(self.building.planImageKey)\(level)"
            if let image = UIImage(named: imageKey) {
                planLayers[level] =
                    ImageLayer(identifier: "\(identifier)-floor-\(level)", polygon: building.quadPolygon,
                                  image: image,
                                  attributes: ImageLayerAttributes(visibility: ZoomableInfo<Bool>([MapZoomLevel.Building: true], defaultValue: false)))                
            }
        }
        
        self.planLayers = planLayers
        
        
        let fillDefaultValue = self.planLayers.isEmpty
        
        let fill = FillLayerAttributes(fillColor: FatecColors.branco,
                                       visibility: ZoomableInfo<Bool>([.Fatec: true], defaultValue: fillDefaultValue))
        
        self.outlineLayer = OutlineLayer(identifier: identifier, coordinates: building.quadPolygon.coordinates,
                                         strokeAttributes: stroke, fillAttributes: fill)
    }
}

class LocationMapHelper {
    let identifier: String
    let location: Location
    let nameLayer: MappingLayer
    
    init(location: Location) {
        self.identifier = "location-\(location.id.code)"
        self.location = location
        self.nameLayer = NameLayer(identifier: identifier, coordinate: location.point, text: location.name,
                                   attributes: SymbolTextLayerAttributes(textSize: ZoomableInfo<Double>(defaultValue: 9.0), visibility: ZoomableInfo<Bool>([MapZoomLevel.Building: true], defaultValue: false),
                                                                         textBlur: Halo(width: ZoomableInfo.init(defaultValue: 0.1), color: UIColor.white, blurWidth: ZoomableInfo.init(defaultValue: 10.0))))
    }
}

class RouteMapHelper {
    let identifier: String
    let route: Route<Location>?
    let leg: LocationRouteLeg?
    let routeLayer: LineLayer
    let circlesLayer: CirclesLayer
    
    init(route: Route<Location>) {
        self.route = route
        self.leg = nil
        self.identifier = "route-\(route.from.id.code)-\(route.to.id.code)"
        self.routeLayer = LineLayer(identifier: self.identifier,
                                    coordinates: route.coordinates,
                                    strokeAttributes: LineLayerAttributes(lineColor: FatecColors.destaque, lineWidth: ZoomableInfo.init(defaultValue: 2.0), visibility: ZoomableInfo.init(defaultValue: 0.75)))
        self.circlesLayer = CirclesLayer(identifier: self.identifier, coordinates: [route.coordinates[0], route.coordinates.last!],
                                         circleAttributes: CircleLayerAttributes(circleColor: FatecColors.vermelho, circleRadius: ZoomableInfo.init(defaultValue: 5.0), opacity: 0.75))
    }
    
    init(leg: LocationRouteLeg) {
        self.route = nil
        self.leg = leg
        self.identifier = "routeleg-\(leg.from.id.code)-\(leg.to.id.code)"
        self.routeLayer = LineLayer(identifier: self.identifier,
                                    coordinates: leg.coordinates,
                                    strokeAttributes: LineLayerAttributes(lineColor: FatecColors.destaque, lineWidth: ZoomableInfo.init(defaultValue: 2.0), visibility: ZoomableInfo.init(defaultValue: 0.75)))
        self.circlesLayer = CirclesLayer(identifier: self.identifier, coordinates: [leg.coordinates[0], leg.coordinates.last!],
                                         circleAttributes: CircleLayerAttributes(circleColor: FatecColors.vermelho, circleRadius: ZoomableInfo.init(defaultValue: 5.0), opacity: 0.75))
    }
}

extension QuadPolygon {
    var mglCoordinateQuad: MGLCoordinateQuad {
        return MGLCoordinateQuad(topLeft: self.coordinates[0],
                                 bottomLeft: self.coordinates[1],
                                 bottomRight: self.coordinates[2],
                                 topRight: self.coordinates[3])
    }
}
