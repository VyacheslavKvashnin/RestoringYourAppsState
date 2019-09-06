/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Data source for the UITableViewController.
*/

import Foundation
import UIKit

class DataSource: NSObject, UITableViewDataSource {
    
    var dataArray = [Item]()
    var storeURL: URL!
    
    private static var sharedDataSource: DataSource = {
        let sharedDataSource = DataSource()
        return sharedDataSource
    }()
    
    class func shared() -> DataSource {
        return sharedDataSource
    }
    
    override private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let dataFileURL = documentsDirectory[0]
        storeURL = dataFileURL.appendingPathComponent("SavedData")
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                let fileData = try Data(contentsOf: storeURL)
                let decoder = PropertyListDecoder()
                if let decodedData = try? decoder.decode(Array<Item>.self, from: fileData) {
                    dataArray = decodedData
                }
            } catch {
                Swift.debugPrint("Couldn't read data file.")
            }
        }
    }
    
    func save() {
        do {
            let encoder = PropertyListEncoder()
            if let encoded = try? encoder.encode(dataArray) {
                try encoded.write(to: storeURL)
            }
        } catch {
            Swift.debugPrint("Couldn't write data file.")
        }
            
    }
    
    // MARK: Accessors
    
    func count() -> Int {
        return dataArray.count
    }
    
    func itemFromIdentifier(_ identifier: String) -> Item {
        let filtered = dataArray.filter { $0.identifier == identifier }
        return filtered[0]
    }
    
    func indexPathForItem(_ item: Item) -> IndexPath? {
        if let index = self.dataArray.firstIndex(of: item) {
            return IndexPath(row: index, section: 0)
        } else {
            return nil
        }
    }

    // MARK: Modifiers
    
    func addItem(_ item: Item) {
        dataArray.append(item)
    }
    
    func itemAtIndex(_ index: Int) -> Item {
        return dataArray[index]
    }
    
    func removeItemAtIndex(_ index: Int) {
        dataArray.remove(at: index)
    }
    
    func insertItem(_ item: Item, index: Int) {
        dataArray.insert(item, at: index)
    }
    
    func replaceItem(_ item: Item, index: Int) {
        dataArray[index] = item
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = dataArray[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
    	return .delete
	}

	func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Allow for editing this row object.
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true // Allow for moving this row object.
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = DataSource.shared().itemAtIndex(sourceIndexPath.row)
        DataSource.shared().removeItemAtIndex(sourceIndexPath.row)
        DataSource.shared().insertItem(itemToMove, index: destinationIndexPath.row)
    }
}
