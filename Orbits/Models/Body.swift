//
//  SolarSystem.swift
//  Orbits
//
//  Created by Ben Lu on 9/14/16.
//  Copyright © 2016 Ben Lu. All rights reserved.
//

import Foundation
import SpaceTime
import MathUtil
import OrderedSet

public protocol Searchable {
    subscript(subId: Int) -> Body? { get }
}

public protocol BoundedByGravity: Searchable {
    var gravParam: Double { get }
    var hillSphere: Double? { get }
    var satellites: OrderedSet<Body> { get }
    func addSatellite(satellite: Body)
}

open class Body: Hashable {
    public static func ==(lhs: Body, rhs: Body) -> Bool {
        return lhs.naif == rhs.naif
    }

    public let naif: Naif
    public var naifId: Int {
        return naif.rawValue
    }
    public var hashValue: Int {
        return naif.hashValue
    }
    public let name: String
    private var centerBodyNaifId: Int?

    // Only set when forming an ephemeris
    public var centerBody: CelestialBody?
    public var motion: OrbitalMotion?

    public var position: Vector3? {
        if naif == Naif.sun {
            return Vector3.zero
        }
        return motion?.position
    }

    public var heliocentricPosition: Vector3? {
        guard let position = position else {
            return nil
        }
        if let b = centerBody, b.naifId == Sun.sol.naifId {
            return position
        } else if let primary = centerBody {
            guard let primaryHelioPosition = primary.heliocentricPosition else {
                return nil
            }
            return primaryHelioPosition + position
        } else {
            return position
        }
    }

    public init(naif: Naif, name: String, centerBodyNaifId: Int? = nil) {
        self.naif = naif
        self.name = name
        self.centerBodyNaifId = centerBodyNaifId
    }
    public func setCenter(naifId: Int?) {
        centerBodyNaifId = naifId
    }
}
