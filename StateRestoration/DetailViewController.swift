/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This sample's detail view controller for each table view cell.
*/

import UIKit

class DetailViewController: UIViewController {
    
    var saveButton: UIBarButtonItem!
    var cancelButton: UIBarButtonItem!
    
    var restoredEditState: Bool = false
    
    @IBOutlet weak var detailName: UITextField!
    @IBOutlet weak var detailNotes: UITextView!
     
    var detailItem: Item? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // Keyboard support observers.
    private var keyboardShowObserver: NSObjectProtocol!
    private var keyboardHideObserver: NSObjectProtocol!
    
    // Text view change observer.
    private var textDidChangeObserver: NSObjectProtocol!
    
    // MARK: - View Controller Lifecycle
    
    // Used by our scene delegate to return an instance of this class from our storyboard.
    static func loadFromStoryboard() -> DetailViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply these buttons later to be used only when in edit mode.
        cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction(_:)))
        saveButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction(_:)))
        
        // Start with just the edit button in the nav bar.
        navigationItem.rightBarButtonItem = editButtonItem
        
        // Restore the editing state (if any)
        isEditing = restoredEditState
        
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        textDidChangeObserver = NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: detailName,
            queue: OperationQueue.main) { (notification) in
                if let textField = notification.object as? UITextField {
                    if let text = textField.text {
                        self.saveButton!.isEnabled = !text.isEmpty
                    } else {
                        self.saveButton!.isEnabled = false
                    }
                }
        }
        
        keyboardShowObserver =
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { [weak self] notification in
                guard let keyboardRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]
                    as? NSValue else { return }
                let frameKeyboard = keyboardRect.cgRectValue
                self?.detailNotes.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frameKeyboard.size.height, right: 0.0)
                self?.view.layoutIfNeeded()
            }
        
        keyboardHideObserver =
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { [weak self] notification in
                self?.detailNotes.contentInset = .zero
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 13.0, *) {
            view.window?.windowScene?.userActivity = nil
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(textDidChangeObserver as Any)
        
        NotificationCenter.default.removeObserver(keyboardShowObserver as Any)
        NotificationCenter.default.removeObserver(keyboardHideObserver as Any)
    }
    
    func restoreItemInterface(_ activityUserInfo: [AnyHashable: Any]) {
        let itemTitle = activityUserInfo[DetailViewController.activityTitleKey] as? String
        let itemNotes = activityUserInfo[DetailViewController.activityNotesKey] as? String
        let itemIdentifier = activityUserInfo[DetailViewController.activityIdentifierKey] as? String
        
        detailItem = Item(title: itemTitle!, notes: itemNotes!, identifier: itemIdentifier)
        
        if let editingState = activityUserInfo[DetailViewController.activityEditStateKey] as? Bool {
            restoredEditState = editingState
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem,
            let detailName = detailName,
            let detailNotes = detailNotes {
                detailName.text = detail.title
                detailNotes.text = detail.notes
            }
    }

    // MARK: - User Actions
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            detailName.becomeFirstResponder()
        }
    }
    
    @objc
    func cancelAction(_ sender: Any) {
        detailItem = DataSource.shared().itemFromIdentifier(detailItem!.identifier)
        endEditState()
    }
    
    @objc
    func saveAction(_ sender: Any) {
        detailItem!.title = detailName.text!
        detailItem!.notes = detailNotes.text!
        
        endEditState()
        
        // Commit this item for save.
        saveItem(detailItem!)
    }
    
    func saveItem(_ item: Item) {
        // Send the notification to the view controller to save this item.
        NotificationCenter.default.post(name: MasterViewController.noteDidChangeNotification, object: item)
    }
    
    // Start editing: save the original title and note, setup the navigation bar.
    func startEditState() {
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = saveButton
    }
    
    // End editing: exit edit mode and reset navigation bar.
    func endEditState() {
        view.endEditing(true)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
}

// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {

    // User ended the edit by tapping "Done" in the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveAction(self)
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        startEditState()
    }

}

// MARK: - UITextViewDelegate

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        startEditState()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text {
            saveButton!.isEnabled = !text.isEmpty
        } else {
            saveButton!.isEnabled = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        endEditState()
    }
  
}

// MARK: - NSUserActivity Support

extension DetailViewController {

    // Encode and decode keys for saving the NSUserActivity to the restoration archive (non-scene based).
    static let restoreActivityKey = "RestoreActivity"
    static let activityTitleKey = "title"
    static let activityNotesKey = "notes"
    static let activityIdentifierKey = "identifier"
    static let activityEditStateKey = "editState"
    
    /** Create the user activity type.
        Note: The activityType string loaded below must be included in your Info.plist file under the `NSUserActivityTypes` array.
            More info: https://developer.apple.com/documentation/foundation/nsuseractivity
    */
    class var activityType: String {
        let activityType = ""
        
        // Load our activity type from our Info.plist.
        if let activityTypes = Bundle.main.infoDictionary?["NSUserActivityTypes"] {
            if let activityArray = activityTypes as? [String] {
                return activityArray[0]
            }
        }
        
        return activityType
    }

    func applyUserActivityEntries(_ activity: NSUserActivity) {
        let itemTitle: [String: String] = [DetailViewController.activityTitleKey: detailName.text!]
        activity.addUserInfoEntries(from: itemTitle)

        let itemNotes: [String: String] = [DetailViewController.activityNotesKey: detailNotes.text!]
        activity.addUserInfoEntries(from: itemNotes)

        // We remember the item's identifier for unsaved changes.
        let itemIdentifier: [String: String] = [DetailViewController.activityIdentifierKey: detailItem!.identifier]
        activity.addUserInfoEntries(from: itemIdentifier)
        
        // Remember the edit mode state to restore next time (we compare the orignal note with the unsaved note).
        let originalItem = DataSource.shared().itemFromIdentifier(detailItem!.identifier)
        let nowEditing = originalItem.title != detailName.text || originalItem.notes != detailNotes.text
        let nowEditingSaveState: [String: Bool] = [DetailViewController.activityEditStateKey: nowEditing]
        activity.addUserInfoEntries(from: nowEditingSaveState)
    }
    
    // Used to construct an NSUserActivity instance for state restoration.
    var detailUserActivity: NSUserActivity {
        let userActivity = NSUserActivity(activityType: DetailViewController.activityType)
        userActivity.title = "Restore Item"
        applyUserActivityEntries(userActivity)
        return userActivity
    }

}

// MARK: - UIUserActivityRestoring

extension DetailViewController {
    
    override func updateUserActivityState(_ activity: NSUserActivity) {
        super.updateUserActivityState(activity)
        applyUserActivityEntries(activity)
    }

    override func restoreUserActivityState(_ activity: NSUserActivity) {
         super.restoreUserActivityState(activity)
        
        // Check if the activity is of our type.
        if activity.activityType == DetailViewController.activityType {
            // Get the user activity data.
            if let activityUserInfo = activity.userInfo {
                restoreItemInterface(activityUserInfo)
            }
        }
    }

}

// MARK: - State Restoration (UIStateRestoring)

extension DetailViewController {
    
/// - Tag: encodeRestorableState
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)

        let encodedActivity = NSUserActivityEncoder(detailUserActivity)
        coder.encode(encodedActivity, forKey: DetailViewController.restoreActivityKey)
    }
   
/// - Tag: decodeRestorableState
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
    
}

