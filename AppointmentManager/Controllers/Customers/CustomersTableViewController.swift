import CoreData
import UIKit

class CustomersTableViewController: UITableViewController {
    
    //MARK: Fetched results controller
    lazy var fetchedResultsController: NSFetchedResultsController<Customer> = {
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Customer> = Customer.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true)]
        
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }()

    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        navigationItem.leftBarButtonItem = self.editButtonItem
        configureDetailView()
    }
    
    func configureDetailView() {
        guard let customers = fetchedResultsController.fetchedObjects else { return }
        if customers.count > 0 {
            tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
        } else {
            splitViewController?.viewControllers.last?.view.isHidden = true
        }
    }
}

// MARK: - Table view data source
extension CustomersTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let customer = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
        cell.textLabel?.text = (customer.firstName ?? "") + " " + (customer.lastName ?? "")
        return cell
    }

}

//MARK: Table actions
extension CustomersTableViewController {
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, complete) in
            let customerCoreDataManager = CustomerCoreDataManager()
            customerCoreDataManager.delete(self.fetchedResultsController.object(at: indexPath))
            customerCoreDataManager.saveContext()
            complete(true)
            
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let customerDetailVc = storyboard?.instantiateViewController(withIdentifier: "CustomerDetailsViewController") as! CustomerDetailsViewController
        customerDetailVc.customer = fetchedResultsController.object(at: indexPath)
        let navigationVc = UINavigationController(rootViewController: customerDetailVc)
        splitViewController?.showDetailViewController(navigationVc, sender: self)
    }
}

//MARK: Fetched results controller delegate
extension CustomersTableViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
            case .insert:
                if let indexPath = newIndexPath {
                    self.tableView.insertRows(at: [indexPath], with: .fade)
                }
                break
            case .delete:
                if let deletedIndexPath = indexPath {
                    self.tableView.deleteRows(at: [deletedIndexPath], with: .automatic)
                    configureDetailView()
                }
                break
            default:
                print("...")
        }
    }
    
}
