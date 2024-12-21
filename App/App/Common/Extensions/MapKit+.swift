//
//  MapKit+.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2022/12/31.
//

import MapKit

// Equatable
extension MKCoordinateRegion: Equatable, CustomStringConvertible {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center == rhs.center && lhs.span == rhs.span
    }

    public var description: String {
        "C = \(center.latitude.shortString(3)), \(center.longitude.shortString(3)), S = \(span.latitudeDelta.shortString(3)), \(span.longitudeDelta.shortString(3))"
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

extension MKCoordinateSpan: Equatable {
    public static func == (lhs: MKCoordinateSpan, rhs: MKCoordinateSpan) -> Bool {
        lhs.latitudeDelta == rhs.latitudeDelta && lhs.longitudeDelta == rhs.longitudeDelta
    }
}
