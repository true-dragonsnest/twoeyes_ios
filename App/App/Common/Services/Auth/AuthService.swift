//
//  AuthService.swift
//  DragonHeart
//
//  Created by Yongsik Kim on 5/6/24.
//

import Foundation

public struct AuthUserInfo {
    public var name: String?
    public var email: String?
    public var profilePictureUrl: String?
    public var phoneNumber: String?

    public init(name: String? = nil, email: String? = nil, profilePictureUrl: String? = nil, phoneNumber: String? = nil) {
        self.name = name
        self.email = email
        self.profilePictureUrl = profilePictureUrl
        self.phoneNumber = phoneNumber
    }
}
