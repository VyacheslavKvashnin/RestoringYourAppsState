/*
See LICENSE folder for this sample’s licensing information.

Abstract:
NSUserActivity-related material for state restoration.
*/

import Foundation

// MARK: - NSUserActivity Encoding-Decoding Support

/** NSUserActivity does not conform to NSCoding protocol, so we have a convenience wrapper class
    to be used to store this user activity as an archive for non-scene state restoration.
*/
class NSUserActivityEncoder: NSObject, NSCoding {
    private let activityTypeKey = "activityType"
    private let activityTitleKey = "activityTitle"
    private let activityUserInfoKey = "activityUserInfo"
    
    private (set) var userActivity: NSUserActivity

    init(_ userActivity: NSUserActivity) {
        self.userActivity = userActivity
    }

    required init?(coder: NSCoder) {
        if let activityType = coder.decodeObject(forKey: activityTypeKey) as? String {
            userActivity = NSUserActivity(activityType: activityType)
            if let title = coder.decodeObject(forKey: activityTitleKey) as? String {
                userActivity.title = title
            }
            if let userInfo = coder.decodeObject(forKey: activityUserInfoKey) as? [AnyHashable: Any] {
                userActivity.userInfo = userInfo
            }
        } else {
            return nil
        }
    }

    func encode(with coder: NSCoder) {
        coder.encode(userActivity.activityType, forKey: activityTypeKey)
        coder.encode(userActivity.title, forKey: activityTitleKey)
        coder.encode(userActivity.userInfo, forKey: activityUserInfoKey)
    }
}
