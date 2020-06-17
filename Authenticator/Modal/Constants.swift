//
//  Constants.swift
//  Authenticator
//
//  Copyright © 2019 Ping Identity. All rights reserved.
//

import Foundation
struct DefaultsKeys{
    static let isPairedKey                                  = "authenticator_is_paired_key"
    static let isUserAdded                                  = "authenticator_is_user_added_key"
    static let notificationPermissionCounter                = "notification_permission_counter"
    static let maxNotificationPersmissionRequests           = 5
    static let minCharactersForPairKey                      = 14
    static let supportID                                    = "support_id"
    static let notificationMethodType                       = "user"
    static let sendLogsKey                                  = "sendLogs"
    static let menuTableViewCellKey                         = "MenuTableViewCell"
    static let storyboardKey                                = "Main"
    static let usersDefaultKey                              = "usersDictionary"
    static let userTableViewCellKey                         = "UserTableViewCell"
}

struct ServerErrors {
    static let timeoutError                                 = 10009
}

struct ViewControllerKeys {
    static let StatusVcID                                   = "StatusVcID"
    static let UsersVcID                                    = "UsersVcID"
    static let PairVcID                                     = "PairVcID"
    static let AuthVcID                                     = "AuthVcID"
    static let NotificationVcID                             = "NotificationVcID"
}

struct NotificationKeys {
    static let toggleSideMenuStart                          = "ToggleSideMenuStart"
    static let toggleSideMenuEnd                            = "ToggleSideMenuEnd"
    static let sendLogs                                     = "sendLogs"
    static let sideMenuReload                               = "sideMenuReload"
}

struct Push {
    static let aps                     = "aps"
    static let alert                   = "alert"
    static let title                   = "title-loc-key"
    static let body                    = "loc-key"
}
