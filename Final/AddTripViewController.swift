import UIKit
import CoreData

class AddTripViewController: UIViewController {
    @IBOutlet weak var tripNameTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Trip"
        setupUI()
        setupTapGesture()
        tripNameTextField.delegate = self
        destinationTextField.delegate = self
        tripNameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        destinationTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
    }

    private func setupUI() {
        saveButton.layer.cornerRadius = 8
        saveButton.backgroundColor = UIColor(named: "SecondaryColor")
        saveButton.setTitleColor(.white, for: .normal)
    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func textFieldEditingChanged(_ sender: UITextField) {
        let isFormValid = !(tripNameTextField.text?.isEmpty ?? true) &&
                          !(destinationTextField.text?.isEmpty ?? true)
        saveButton.isEnabled = isFormValid
        saveButton.alpha = isFormValid ? 1.0 : 0.5
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let tripName = tripNameTextField.text, !tripName.isEmpty,
              let destination = destinationTextField.text, !destination.isEmpty else {
            showAlert(message: "Please fill in all fields.")
            return
        }

        if startDatePicker.date > endDatePicker.date {
            showAlert(message: "Start date cannot be after the end date.")
            return
        }

        saveTrip(tripName: tripName, destination: destination, startDate: startDatePicker.date, endDate: endDatePicker.date)
    }

    private func saveTrip(tripName: String, destination: String, startDate: Date, endDate: Date) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let trip = Trip(context: context)
        trip.name = tripName
        trip.destination = destination
        trip.startDate = startDate
        trip.endDate = endDate

        do {
            try context.save()
            clearFields()
            navigationController?.popViewController(animated: true)
        } catch {
            showAlert(message: "Failed to save trip. Please try again.")
        }
    }

    private func clearFields() {
        tripNameTextField.text = ""
        destinationTextField.text = ""
        startDatePicker.date = Date()
        endDatePicker.date = Date()
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddTripViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == tripNameTextField {
            destinationTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
