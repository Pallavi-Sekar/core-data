import UIKit
import CoreData

class TripExpensesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var trip: Trip? // Property to hold the selected trip
    var expenses: [Expense] = [] // Array to hold expenses related to the trip

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var expenseAmountTextField: UITextField!
    @IBOutlet weak var totalExpensesLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up table view delegate and data source
        tableView.delegate = self
        tableView.dataSource = self

        // Register UITableViewCell with subtitle style
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "expenseCell")

        // Fetch expenses related to the trip
        fetchExpenses()
        calculateTotalExpenses()
    }

    // MARK: - Core Data Fetching

    private func fetchExpenses() {
        guard let trip = trip, let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trip == %@", trip)

        do {
            expenses = try context.fetch(fetchRequest)
            tableView.reloadData() // Reload the table view after fetching data
        } catch {
            print("Error fetching expenses: \(error)")
        }
    }

    // MARK: - Calculating Total Expenses

    private func calculateTotalExpenses() {
        let total = expenses.reduce(0.0) { $0 + $1.amount }
        totalExpensesLabel.text = String(format: "$%.2f", total)
    }

    // MARK: - Saving Expense

    @IBAction func saveExpense(_ sender: UIButton) {
        guard let expenseName = expenseNameTextField.text, !expenseName.isEmpty,
              let amountText = expenseAmountTextField.text, let amount = Double(amountText), amount > 0 else {
            // Show an alert if inputs are invalid
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter valid expense name and amount.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        // Save the expense to Core Data
        guard let trip = trip, let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let expense = Expense(context: context)
        expense.expenseName = expenseName
        expense.amount = amount
        expense.trip = trip

        do {
            try context.save() // Save the context
            expenses.append(expense) // Add the new expense to the array
            tableView.reloadData() // Reload the table view
            calculateTotalExpenses() // Recalculate total expenses
        } catch {
            print("Error saving expense: \(error)")
        }

        // Clear the text fields
        expenseNameTextField.text = ""
        expenseAmountTextField.text = ""
    }

    // MARK: - UITableViewDataSource Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the reusable cell with subtitle style
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell", for: indexPath)
        
        let expense = expenses[indexPath.row]
        cell.textLabel?.text = expense.expenseName
        cell.detailTextLabel?.text = String(format: "$%.2f", expense.amount) // Display the amount with two decimal places
        
        return cell
    }

    // MARK: - Deleting an Expense

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteExpense(at: indexPath)
        }
    }

    private func deleteExpense(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let expenseToDelete = expenses[indexPath.row]
        context.delete(expenseToDelete)

        do {
            try context.save() // Save the context after deletion
            expenses.remove(at: indexPath.row) // Remove the expense from the array
            tableView.deleteRows(at: [indexPath], with: .fade) // Update the table view
            calculateTotalExpenses() // Recalculate total expenses
        } catch {
            print("Error deleting expense: \(error)")
        }
    }
}
