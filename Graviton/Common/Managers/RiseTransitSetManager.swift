//
//  RiseTransitSetManager.swift
//  Graviton
//
//  Created by Ben Lu on 5/12/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import CoreLocation
import Orbits
import SpaceTime
import UIKit

final class RiseTransitSetManager: LocationSensitiveSubscriptionManager<[Naif: RiseTransitSetElevation]> {
    static var globalMode: Horizons.FetchMode = .preferLocal

    static let `default` = RiseTransitSetManager()

    override func fetch(mode: Horizons.FetchMode? = nil, forJulianDay requestedJd: JulianDay = JulianDay.now) {
        if isFetching { return }
        isFetching = true
        let site = ObserverSite(naif: .majorBody(.earth), location: LocationManager.default.content ?? CLLocation())
        Horizons.shared.fetchRiseTransitSetElevation(preferredDate: requestedJd.date, observerSite: site, mode: mode ?? RiseTransitSetManager.globalMode, update: { [weak self] dict in
            self!.content = dict
            for (_, sub) in self!.subscriptions {
                DispatchQueue.main.async {
                    sub.didLoad!(dict)
                }
            }
        }, complete: { [weak self] _, _ in
            self!.isFetching = false
        })
    }

    override func update(subscription _: LocationSensitiveSubscriptionManager<[Naif: RiseTransitSetElevation]>.Subscription, forJulianDay _: JulianDay) {
        guard let rtse = content?.first?.value else { return }
        if JulianDay.now > rtse.endJd {
            // fetch RTS info for new day
            fetch()
        }
    }
}
