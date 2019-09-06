/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This sample's main view controller.
*/

import UIKit

class MasterViewController: UITableViewController {
    
    static let noteDidChangeNotification = NSNotification.Name("noteDidChangeNotification")
    private var noteDidChangeObserver: NSObjectProtocol!
    
    // MARK: View Controller Lifecycle
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        // Add to this class an observer when a note changes.
        noteDidChangeObserver =
            NotificationCenter.default.addObserver(forName: MasterViewController.noteDidChangeNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { notification in
                    // A note needs to be saved.
                    if let item = notification.object as? Item {
                        // Find the item to replace with the incoming 'item'.
                        let itemToReplace = DataSource.shared().itemFromIdentifier(item.identifier)
                        if let itemToReplaceIndexPath = DataSource.shared().indexPathForItem(itemToReplace) {
                            DataSource.shared().replaceItem(item, index: itemToReplaceIndexPath.row)
                            DataSource.shared().save()

                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at: [itemToReplaceIndexPath], with: .automatic)
                            self.tableView.endUpdates()
                        }
                }
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(MasterViewController.insertNewObject(_:)))
        self.navigationItem.leftBarButtonItem = addButton
        
        tableView.dataSource = DataSource.shared()

        if DataSource.shared().count() == 0 {
            // Save 10 default note items.
            for index in 1...9 {
                DataSource.shared().addItem(Item(title: "Item \(index)", notes: "Item \(index) notes", identifier: nil))
            }
            DataSource.shared().save()
        }
    }
    
    @objc
    func insertNewObject(_ sender: AnyObject) {
        let newIndex = DataSource.shared().count()
        let itemToInsert = Item(title: "Item \(newIndex + 1)", notes: "Item \(newIndex + 1) notes", identifier: nil)
        DataSource.shared().insertItem(itemToInsert, index: newIndex)
        
        let indexPath = IndexPath(row: newIndex, section: 0)
        self.tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let item = DataSource.shared().itemAtIndex(indexPath.row)
                if let detailViewController = segue.destination as? DetailViewController {
                    // Pass the item to the detail view controller for editing.
                    detailViewController.detailItem = item
                }
            }
        }
    }

}

