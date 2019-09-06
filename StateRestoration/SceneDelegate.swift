/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The scene delegate for the main application.
*/

import UIKit

@available(iOS 13.0, *)
@objc
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    /** Applications should configure their UIWindow, and attach the UIWindow to the provided UIWindowScene scene.
 
        If using a storyboard file (as specified by the Info.plist key, UISceneStoryboardFile,
        the window property will automatically be configured and attached to the windowScene.
 
        Remember to retain the SceneDelegate 's UIWindow.
        The recommended approach is for the SceneDelegate to retain the scene's window.
    */
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Do we have an activity to restore?
        if let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity {
            // Setup the detail view controller with it's restoration activity.
            if !configure(window: window, with: userActivity) {
                print("Failed to restore DetailViewController from \(userActivity)")
            }
        }
    }
    
    func configure(window: UIWindow?, with activity: NSUserActivity) -> Bool {
        if let detailViewController = DetailViewController.loadFromStoryboard() {
            if let navigationController = window?.rootViewController as? UINavigationController {
                navigationController.pushViewController(detailViewController, animated: false)
                detailViewController.restoreUserActivityState(activity)
                return true
            }
        }
        return false
    }
    
    /** Called as the scene is being released by the system or on window close.
        This occurs shortly after the scene enters the background, or when its session is discarded.
        Release any resources associated with this scene that can be re-created the next time the scene connects.
        The scene may re-connect later, as its session was not neccessarily discarded (see`application:didDiscardSceneSessions` instead).
    */
    func sceneDidDisconnect(_ scene: UIScene) {
        //..
    }
    
    /** Called as the scene transitions from the background to the foreground,
        on window open or in iOS resume.
        Use this method to undo the changes made on entering the background.
    */
    func sceneWillEnterForeground(_ scene: UIScene) {
        //..
    }
    
    /** Called as the scene transitions from the foreground to the background.
        Use this method to save data, release shared resources, and store enough scene-specific state information
        to restore the scene back to its current state.
     */
    func sceneDidEnterBackground(_ scene: UIScene) {
        //..
    }
    
    /** Called when the scene "will move" from an active state to an inactive state,
        on window close or in iOS enter background.
        This may occur due to temporary interruptions (ex. an incoming phone call).
    */
/// - Tag: sceneWillResignActive
    func sceneWillResignActive(_ scene: UIScene) {
        if let navController = window!.rootViewController as? UINavigationController {
            if let detailViewController = navController.viewControllers.last as? DetailViewController {
                // Fetch the user activity from our detail view controller so restore for later.
                scene.userActivity = detailViewController.detailUserActivity
            }
        }
    }
    
    /** Called when the scene "has moved" from an inactive state to an active state.
        Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        Is called every time a scene becomes active, so setup your scene UI here.
    */
    func sceneDidBecomeActive(_ scene: UIScene) {
        //..
    }
    
// MARK: State Restoration

    // This is the NSUserActivity that will be used to restore state when the scene reconnects.
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

}
