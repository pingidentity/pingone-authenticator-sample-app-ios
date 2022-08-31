//
//  Constants.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import Foundation
struct DefaultsKeys {
    static let isPairedKey                                  = "authenticator_is_paired_key"
    static let isUserAdded                                  = "authenticator_is_user_added_key"
    static let notificationPermissionCounter                = "notification_permission_counter"
    static let maxNotificationPersmissionRequests           = 5
    static let shortPairKeyCount                            = 14
    static let longPairKeyCount                             = 18
    static let minCharactersForAuthCode                     = 8
    static let sideMenuCellHeight                           = 44
    static let supportID                                    = "support_id"
    static let notificationMethodType                       = "user"
    static let sendLogsKey                                  = "sendLogs"
    static let menuTableViewCellKey                         = "MenuTableViewCell"
    static let storyboardKey                                = "Main"
    static let usersDefaultKey                              = "usersDictionary"
    static let userTableViewCellKey                         = "UserTableViewCell"
    static let userQRAuthTableViewCell                      = "UserQRAuthTableViewCell"
}

struct ServerErrors {
    static let timeoutError                                 = 10009
}

struct ViewControllerKeys {
    static let StatusVcID                                   = "StatusVcID"
    static let UsersVcID                                    = "UsersVcID"
    static let PairVcID                                     = "PairVcID"
    static let AuthVcID                                     = "AuthVcID"
    static let AuthScanVcID                                 = "AuthScanVcID"
    static let AuthSelectionVcID                            = "AuthSelectionVcID"
    static let NotificationVcID                             = "NotificationVcID"
}

struct NotificationKeys {
    static let toggleSideMenuStart                          = "ToggleSideMenuStart"
    static let toggleSideMenuEnd                            = "ToggleSideMenuEnd"
    static let sendLogs                                     = "sendLogs"
    static let sideMenuReload                               = "sideMenuReload"
    static let scanQRMenuTapped                             = "scanQRMenuTapped"
}

struct Push {
    static let aps                                          = "aps"
    static let alert                                        = "alert"
    static let title                                        = "title-loc-key"
    static let body                                         = "loc-key"
}

struct Alert {
    static let copied                                       = "Copied"
}

struct AuthenticateCode {
    static let userApprovalNotRequired                      = "NOT_REQUIRED"
    static let userApprovalRequired                         = "REQUIRED"
    static let statusCompleted                              = "COMPLETED"
    static let statusDenied                                 = "DENIED"
    static let statusExpired                                = "EXPIRED"
    static let statusClaimed                                = "CLAIMED"
}

struct AssetsName {
    static let checkmarkOn                                  = "checkmark_on"
    static let checkmarkOff                                 = "checkmark_off"
}
