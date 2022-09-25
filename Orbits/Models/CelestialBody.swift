//
//  CelestialBody.swift
//  Orbits
//
//  Created by Ben Lu on 1/28/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import Foundation
import MathUtil
import OrderedSet

open class CelestialBody: Body, BoundedByGravity, CustomStringConvertible, Comparable {

    /// radius in m
    public let radius: Double
    /// rotation period in hr
    public let rotationPeriod: Double
    public let obliquity: DegreeAngle
    public let gravParam: Double
    public let hillSphereRadiusRespectToRadius: Double?
    public var hillSphere: Double? {
        if let radRp = hillSphereRadiusRespectToRadius {
            return radRp * radius
        }
        return nil
    }

    /// mass in kg
    public var mass: Double {
        return gravParam / gravConstant * 10e8
    }

    public let satellites = OrderedSet<Body>()

    public var description: String {
        return "CelestialBody: { naif: \(naifId), name: \(name), radius(m): \(radius), rotationPeriod(s): \(rotationPeriod), obliquity(radians): \(obliquity), gm: \(gravParam), hillSphere(m): \(String(describing: hillSphere))}"
    }

    public init(naifId: Int, name: String, gravParam: Double, radius: Double, rotationPeriod: Double = 0, obliquity: DegreeAngle = DegreeAngle(0), centerBodyNaifId: Int? = nil, hillSphereRadRp: Double? = nil) {
        self.gravParam = gravParam
        self.radius = radius
        self.rotationPeriod = rotationPeriod
        self.obliquity = obliquity
        self.hillSphereRadiusRespectToRadius = hillSphereRadRp
        super.init(naif: Naif(naifId: naifId), name: name, centerBodyNaifId: centerBodyNaifId)
    }

    public convenience init(naifId: Int, name: String, mass: Double, radius: Double, rotationPeriod: Double = 0, obliquity: DegreeAngle = DegreeAngle(0), centerBodyNaifId: Int? = nil, hillSphereRadRp: Double? = nil) {
        self.init(naifId: naifId, name: name, gravParam: mass * gravConstant, radius: radius, rotationPeriod: rotationPeriod, obliquity: obliquity, centerBodyNaifId: centerBodyNaifId, hillSphereRadRp: hillSphereRadRp)
    }

    public convenience init(naifId: Int, mass: Double, radius: Double, rotationPeriod: Double = 0, obliquity: DegreeAngle = DegreeAngle(0), centerBodyNaifId: Int? = nil, hillSphereRadRp: Double? = nil) {
        let name = NaifCatalog.name(forNaif: naifId)!
        self.init(naifId: naifId, name: name, mass: mass, radius: radius, rotationPeriod: rotationPeriod, obliquity: obliquity, centerBodyNaifId: centerBodyNaifId, hillSphereRadRp: hillSphereRadRp)
    }

    public convenience init(naifId: Int, gravParam: Double, radius: Double, rotationPeriod: Double = 0, obliquity: DegreeAngle = DegreeAngle(0), centerBodyNaifId: Int? = nil, hillSphereRadRp: Double? = nil) {
        let name = NaifCatalog.name(forNaif: naifId)!
        self.init(naifId: naifId, name: name, gravParam: gravParam, radius: radius, rotationPeriod: rotationPeriod, obliquity: obliquity, centerBodyNaifId: centerBodyNaifId, hillSphereRadRp: hillSphereRadRp)
    }

    public func addSatellite(satellite: Body) {
        satellites.append(satellite)
        satellite.setCenter(naifId: naifId)
    }

    public subscript(subId: Int) -> Body? {
        let targets = satellites.filter { $0.naifId == subId }
        if targets.isEmpty == false {
            return targets[0]
        }
        for satellite in satellites {
            guard let orbitable = satellite as? BoundedByGravity else {
                continue
            }
            if let target = orbitable[subId] {
                return target
            }
        }
        return nil
    }

    public static func ==(lhs: CelestialBody, rhs: CelestialBody) -> Bool {
        return lhs.naif == rhs.naif
    }

    public static func <(lhs: CelestialBody, rhs: CelestialBody) -> Bool {
        return lhs.naif < rhs.naif
    }

    // MARK: - NSCopying
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = CelestialBody(naifId: naifId, name: name, gravParam: gravParam, radius: radius, rotationPeriod: rotationPeriod, obliquity: obliquity, centerBodyNaifId: centerBody?.naifId, hillSphereRadRp: hillSphereRadiusRespectToRadius)
        copy.motion = motion?.copy() as? OrbitalMotion
        let children = satellites.filter { $0 is CelestialBody } as! [CelestialBody]
        children.forEach { (child) in
            let copiedChild = child.copy() as! CelestialBody
            copy.addSatellite(satellite: copiedChild)
            copiedChild.centerBody = copy
        }
        return copy
    }
}

public class Sun: CelestialBody {
    public static var sol: Sun {
        return Sun(naifId: 10, name: "Sun", mass: 1.988544e30, radius: 6.955e8)
    }
}
