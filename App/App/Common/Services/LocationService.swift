//
//  LocationService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 2023/03/04.
//

import Combine
import CoreLocation
import Foundation

private let T = #fileID

private extension CLAuthorizationStatus {
    var string: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .restricted: return "restricted"
        case .denied: return "deniued"
        @unknown default: return "unknown"
        }
    }
}

public class LocationService: NSObject, CLLocationManagerDelegate {
    public enum AccessStatus {
        case notDetermined
        case denied
        case authorized
    }

    public struct Location {
        public let latitude: Double
        public let longitude: Double
        public let administrativeArea: String?
        public let locality: String?
        public let throughfare: String?
        public let subThroughfare: String?

        public init(latitude: Double, longitude: Double, administrativeArea: String? = nil, locality: String? = nil, throughfare: String? = nil, subThroughfare: String? = nil) {
            self.latitude = latitude
            self.longitude = longitude
            self.administrativeArea = administrativeArea
            self.locality = locality
            self.throughfare = throughfare
            self.subThroughfare = subThroughfare
        }
    }

    private lazy var manager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        return m
    }()

    private var checkAccessCompletion: ((Result<Void, Error>) -> Void)?

    public private(set) var accessStatus: AccessStatus = .notDetermined

    public var location = CurrentValueSubject<Location?, Never>(nil)

    public static let shared = LocationService()
    override private init() {}

    public func start(completion: @escaping (Result<Void, Error>) -> Void) {
        checkAccess { result in
            if case let .failure(error) = result {
                "check access failed : \(error)".le(T)
                completion(.failure(error))
                return
            }

            DispatchQueue.main.async {
                self.manager.desiredAccuracy = kCLLocationAccuracyHundredMeters // TODO: configurable
                self.manager.requestLocation()

                "started".ld(T)
                completion(.success(()))
            }
        }
    }

    public func stop() {
        DispatchQueue.main.async {
            self.manager.stopUpdatingLocation()
        }
    }

    private func checkAccess(completion: ((Result<Void, Error>) -> Void)?) {
        let authStatus: CLAuthorizationStatus = manager.authorizationStatus
        "authStatus = \(authStatus)".ld(T)

        switch authStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            accessStatus = .authorized
            completion?(.success(()))

        case .restricted, .denied:
            accessStatus = .denied
            completion?(.failure(AppError.accessDenied()))

        case .notDetermined: fallthrough
        @unknown default:
            accessStatus = .notDetermined
            checkAccessCompletion = completion
            DispatchQueue.main.async {
                self.manager.requestWhenInUseAuthorization() // TODO: configurable
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

public extension LocationService {
    func locationManager(_: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        "didChangeAuthorization : \(status)".ld(T)
        checkAccess(completion: checkAccessCompletion)
    }

    func locationManagerDidChangeAuthorization(_: CLLocationManager) {
        "locationManagerDidChangeAuthorization".ld(T)
        checkAccess(completion: checkAccessCompletion)
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        "location : \(location)".ld(T)

        Self.geoLocation(from: location) { result in
            guard case let .success(geoLoc) = result else {
                return
            }
            self.location.value = geoLoc
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        "didFailWithError : \(error)".le(T)
        checkAccessCompletion?(.failure(error))
    }

    static func geoLocation(from location: CLLocation, handler: @escaping (Result<Location, AppError>) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placeMarks, error in
            if let error = error {
                "failed to reverse geocode : \(error)".le(T)
                handler(.failure(AppError(error)))
                return
            }
            guard let placeMark = placeMarks?.first else {
                handler(.failure(AppError.generalError("no place mark from location : \(location)".le(T))))
                return
            }

            let geoLocation = Location(latitude: location.coordinate.latitude,
                                       longitude: location.coordinate.longitude,
                                       administrativeArea: placeMark.administrativeArea,
                                       locality: placeMark.locality,
                                       throughfare: placeMark.thoroughfare,
                                       subThroughfare: placeMark.subLocality)
            handler(.success(geoLocation))
        }
    }
}
