import UIKit

class TripDetailViewController: UITableViewController {

    var trip: Trip? // Property to hold the passed trip object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // You can set the title or any other setup here
        title = trip?.name ?? "Trip Details"
        
        // Register the default UITableViewCell or your custom cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "detailCell")
    }

    // MARK: - TableView DataSource Methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Only one section for this simple case
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4 // One row for each detail (name, destination, start date, end date)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
        
        // Set up the cell based on the row index
        if let trip = trip {
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Trip Name: \(trip.name ?? "N/A")"
            case 1:
                cell.textLabel?.text = "Destination: \(trip.destination ?? "N/A")"
            case 2:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                if let startDate = trip.startDate {
                    cell.textLabel?.text = "Start Date: \(dateFormatter.string(from: startDate))"
                } else {
                    cell.textLabel?.text = "Start Date: N/A"
                }
            case 3:
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                if let endDate = trip.endDate {
                    cell.textLabel?.text = "End Date: \(dateFormatter.string(from: endDate))"
                } else {
                    cell.textLabel?.text = "End Date: N/A"
                }
            default:
                break
            }
        }
        
        return cell
    }

    // MARK: - Optional: Handle Row Selection (if needed)

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Handle row selection if needed
    }

    // MARK: - Navigation

    // This method will be triggered when the "Expenses" button is tapped
    private func showTripExpenses() {
        if let trip = trip {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let tripExpensesVC = storyboard.instantiateViewController(withIdentifier: "expenseCell") as? TripExpensesViewController {
                tripExpensesVC.trip = trip // Pass the trip object
                navigationController?.pushViewController(tripExpensesVC, animated: true)
            }
        }
    }

    // Button action for showing expenses
    @IBAction func expensesButtonTapped(_ sender: UIButton) {
        showTripExpenses() // Directly push the TripExpensesViewController
    }
}
