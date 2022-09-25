//
//  CelestialBodyObserverInfoManager.swift
//  Graviton
//
//  Created by Sihao Lu on 5/14/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import CoreLocation
import Orbits
import SpaceTime
import UIKit

final class CelestialBodyObserverInfoManager: LocationSensitiveSubscriptionManager<[Naif: CelestialBodyObserverInfo]> {
    static var globalMode: Horizons.FetchMode = .preferLocal

    static let `default` = CelestialBodyObserverInfoManager()

    override func fetch(mode: Horizons.FetchMode? = nil, forJulianDay requestedJd: JulianDay) {
        if isFetching { return }
        isFetching = true
        let site = ObserverSite(naif: .majorBody(.earth), location: LocationManager.default.content ?? CLLocation())
        Horizons.shared.fetchCelestialBodyObserverInfo(preferredDate: requestedJd.date, observerSite: site, mode: mode ?? CelestialBodyObserverInfoManager.globalMode, update: { [weak self] dict in
            self?.content = dict
            for (_, sub) in self!.subscriptions {
                DispatchQueue.main.async {
                    sub.didLoad!(dict)
                }
            }
        }, complete: { [weak self] _, _ in
            self!.isFetching = false
        })
    }

    override func update(subscription _: LocationSensitiveSubscriptionManager<[Naif: CelestialBodyObserverInfo]>.Subscription, forJulianDay _: JulianDay) {
        // no-op
    }
}
