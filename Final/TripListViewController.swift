import UIKit
import CoreData

class TripListViewController: UITableViewController {

    var trips: [Trip] = [] // Array to hold trip objects

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Fetch trips from Core Data
        fetchTrips()
    }

    deinit {
        
    }

    // MARK: - Core Data fetching

    private func fetchTrips() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()

        do {
            trips = try context.fetch(fetchRequest)
            tableView.reloadData() // Reload table view after fetching data
        } catch {
            print("Error fetching trips: \(error)")
        }
    }

    @objc private func refreshTrips() {
        // Refresh the trips when a new trip is added
        fetchTrips()
    }

    // MARK: - UITableViewDataSource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue reusable cell or create a new one
        let cell = tableView.dequeueReusableCell(withIdentifier: "myTripsPageTapped")
                    ?? UITableViewCell(style: .subtitle, reuseIdentifier: "myTripsPageTapped")

        let trip = trips[indexPath.row]
        cell.textLabel?.text = trip.name ?? "Unnamed Trip"

        // Prepare detail text
        var details = "Destination: \(trip.destination ?? "N/A")"
        if let startDate = trip.startDate, let endDate = trip.endDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            details += "\nStart: \(dateFormatter.string(from: startDate)) | End: \(dateFormatter.string(from: endDate))"
        }
        cell.detailTextLabel?.text = details

        // Enable multiple lines for the detail text
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTrip(at: indexPath)
        }
    }

    // MARK: - Deleting a trip

    private func deleteTrip(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let tripToDelete = trips[indexPath.row]
        context.delete(tripToDelete)

        do {
            try context.save() // Save the context after deletion
            trips.remove(at: indexPath.row) // Remove the trip from the array
            tableView.deleteRows(at: [indexPath], with: .fade) // Update the table view
        } catch {
            print("Error deleting trip: \(error)")
        }
    }
    
    // MARK: - Navigation

    // Handle row selection to perform segue to TripDetailViewController
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTrip = trips[indexPath.row]
        performSegue(withIdentifier: "showTripDetails", sender: selectedTrip) // Trigger segue to details
    }

    // Prepare the data for the TripDetailViewController before performing the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTripDetails", let tripDetailVC = segue.destination as? TripDetailViewController {
            if let trip = sender as? Trip {
                tripDetailVC.trip = trip // Pass the selected trip to the detail view controller
            }
        }
    }

    // Optional: Log the navigation stack to ensure no duplicate view controllers are pushed
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Navigation Stack Count: \(navigationController?.viewControllers.count ?? 0)")
    }
}
