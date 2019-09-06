# Restoring Your App's State

Preserve and restore information related to the user's current activities.

## Overview

This sample project demonstrates how to preserve your app's state information and restore your app to its previous state on subsequent launches. When using your app, the user takes actions that affect the user interface. For example, the user might view a specific page of information, and after the user exits the app, the operating system might terminate the app to free up the resources it holds. During the subsequent launch, restoring your interface to the previous interaction point provides continuity for the user, and lets them finish active tasks quickly.

This sample app demonstrates the use of state preservation and restoration for scenarios where your app is likely to be interrupted. The sample project manages a set of notes. Each note has a title and content. The user can create, edit, and reorder these notes. The project shows how to preserve and restore a given note in its `DetailViewController`, restoring the note's title and content.

The sample supports two different state preservation approaches. In iOS 13 and later, apps save state for each window scene using [`NSUserActivity`](https://developer.apple.com/documentation/foundation/nsuseractivity) objects. In iOS 12 and earlier, apps preserve the state of their user interface by saving and restoring the configuration of view controllers. 

For additional information about state restoration, see [Preserving Your App's UI Across Launches](https://developer.apple.com/documentation/uikit/view_controllers/preserving_your_app_s_ui_across_launches).

## Configure the Sample Code Project

In Xcode, select your development team on the macOS target's General tab.

## Enable State Preservation and Restoration for Your App

For scene-based apps, UIKit asks each scene to save its state information using an [`NSUserActivity`](https://developer.apple.com/documentation/foundation/nsuseractivity) object. In your own apps, you use the activity object to store information needed to recreate your scene's interface and restore the content of that interface. If your app doesn't support scenes, use the view-controller-based state restoration process to preserve the state of your interface instead. 

To provide the needed activity object, the sample implements the [`stateRestorationActivity(for:)`](https://developer.apple.com/documentation/uikit/uiscenedelegate/3238061-staterestorationactivity) method of its scene delegate object. Implementing this method tells the system that the sample supports user-activity-based state restoration. The implementation of this method returns the activity object already stored in the scene's [`userActivity`](https://developer.apple.com/documentation/uikit/uiresponder/1621089-useractivity) property, which the sample populates when the scene becomes inactive.

``` swift
// This is the NSUserActivity that will be used to restore state when the scene reconnects.
func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
    return scene.userActivity
}
```

For view-controller-based state restoration, this sample opts-in to state preservation and restoration using the app delegate’s [`application(_:shouldSaveApplicationState:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623089-application) and [` application(_:shouldRestoreApplicationState:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622987-application) methods. Both methods return a `Bool` value that indicates whether the step should occur. This sample returns `true` for both functions.

``` swift
func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
    return true
}
```
[View in Source](x-source-tag://shouldSaveApplicationState)

``` swift
func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
    return true
}
```
[View in Source](x-source-tag://shouldRestoreApplicationState)

## Preserve and Restore the App State with an Activity Object

Scene-based state restoration is the recommended way to restore the app’s user interface. An [`NSUserActivity`](https://developer.apple.com/documentation/foundation/nsuseractivity) object captures the app's state at the current moment in time. For example, you might include information about the data your app is currently displaying. The system saves the object you provide and returns it to your app the next time it launches. 

The sample creates a new `NSUserActivity` object when the user closes the app or the app enters the background. At that time, the  [`sceneWillResignActive(_:)`](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622950-applicationwillresignactive) method of the scene delegate creates an activity object only if a detail view controller is visible. If no detail view controller is visible, the app is already displaying the default user interface, and no activity object is necessary.

``` swift
func sceneWillResignActive(_ scene: UIScene) {
    if let navController = window!.rootViewController as? UINavigationController {
        if let detailViewController = navController.viewControllers.last as? DetailViewController {
            // Fetch the user activity from our detail view controller so restore for later.
            scene.userActivity = detailViewController.detailUserActivity
        }
    }
}
```
[View in Source](x-source-tag://sceneWillResignActive)

When the user launches the app again, the sample's  [`scene(_:willConnectTo:options:)`](https://developer.apple.com/documentation/uikit/uiscenedelegate/3197914-scene) method checks for the presence of an activity object. If one is present, the method configures the detail view controller specified by that activity object.

``` swift
func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    // Do we have an activity to restore?
    if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
        // Setup the detail view controller with it's restoration activity.
        if !configure(window: window, with: userActivity) {
            print("Failed to restore DetailViewController from \(userActivity)")
        }
    }
}
```

## Preserve and Restore the App State Using View Controllers

If your app does not yet support scenes, you preserve your app's state by saving the state of its view controller hierarchy. View controllers adopt the [`UIStateRestoring`](https://developer.apple.com/documentation/uikit/uistaterestoring) protocol, which defines methods for saving custom state information to an archive and restoring that information later.

To specify which of your app's view controllers you want to save, assign a restoration identifier to that view controller. A restoration identifier is a string that UIKit uses to identify a view controller or other user interface element. The identifiers you assign to your view controllers must be unique. You may specify them in Interface Builder or in code.

The sample assigns a restoration ID assigned to each view controller in the storyboard file. You can find this information by selecting the view controller and looking in the Identity Inspector. The Storyboard ID for that view controller is usually the same as the Restoration ID.

This sample saves the state information in the detail view controller's [`encodeRestorableState(with:)`](https://developer.apple.com/documentation/appkit/nsresponder/1526236-encoderestorablestate) method, and it restores that state in the [`restoreState(with:)`](https://developer.apple.com/documentation/appkit/nsresponder/1526253-restorestate) method. Because it already encapsulates the view controller's state in an [`NSUserActivity`](https://developer.apple.com/documentation/foundation/nsuseractivity) object, the implementations of these methods operate on the existing activity object. Calling `super` from these methods is required and allows UIKit to restore the rest of the view controller's inherited state.

``` swift
override func encodeRestorableState(with coder: NSCoder) {
    super.encodeRestorableState(with: coder)

    let encodedActivity = NSUserActivityEncoder(detailUserActivity)
    coder.encode(encodedActivity, forKey: DetailViewController.restoreActivityKey)
}
```
[View in Source](x-source-tag://encodeRestorableState)

``` swift
override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    
    if coder.containsValue(forKey: DetailViewController.restoreActivityKey) {
        if let decodedActivity = coder.decodeObject(forKey: DetailViewController.restoreActivityKey) as? NSUserActivityEncoder {
            if let activityUserInfo = decodedActivity.userActivity.userInfo {
                restoreItemInterface(activityUserInfo)
            }
        }
    }
}
```
[View in Source](x-source-tag://decodeRestorableState)


## Test State Restoration on a Device

When debugging your project be aware that the system automatically deletes an app’s preserved state when the user force quits the app. Deleting the preserved state information when the app is killed is a safety precaution. In addition, the system also deletes preserved state if the app crashes at launch time. If you want to test your app’s ability to restore its state, do not use the app switcher to kill the the app during debugging. Instead, use Xcode to kill the app, or kill the app programmatically. One technique is to suspend your app using the Home button, and then stop the debugger in Xcode. When you launch the app again using Xcode, UIKit initiates the state restoration process.


