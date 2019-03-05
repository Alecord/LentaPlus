
import CoreData
import Foundation

class CoreDataManager {
    
    // Singleton
    static let instance = CoreDataManager()
    
    private init() {}
    
    // Entity for Name
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    }

    // Fetched Results Controller for Entity Name
    func fetchedResultsController(entityName: String, keyForSort: String, ascForSort: Bool, limitForFetch: Int) -> NSFetchedResultsController<NSFetchRequestResult> {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: keyForSort, ascending: ascForSort)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = limitForFetch

        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }
    
    func GetTimeLocalosated(modified: Double) -> String {
        let timestamp = NSDate().timeIntervalSince1970
        let mins = (timestamp - modified)/60
        let date = Date(timeIntervalSince1970: modified)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //TimeZone(abbreviation: "GMT +3")
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "d MMM yyyy, HH:mm"
        if mins < 12 * 60  {
            dateFormatter.dateFormat = "HH:mm"
        } else if mins < 1440 {
            dateFormatter.dateFormat = "Сегодня, HH:mm"
        }
        return dateFormatter.string(from: date)
    }
    
    func GetRubricTitle(name: String) -> String {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Rubric")
        fetchRequest.predicate = NSPredicate(format: "id = %@", name)
        do {
            let results = try CoreDataManager.instance.managedObjectContext.fetch(fetchRequest) as? [Rubric]
            if results?.count != 0 {
                return results?[0].title ?? name
            }
        } catch {
            print("Fetch Failed: \(error)")
        }
        return name
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LentaPlus")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()

    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}
