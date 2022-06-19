//
//  ViewController.swift
//  InterestingNumbers
//
//  Created by Daniil Klimenko on 18.06.2022.
//

import UIKit

class MainViewController: UIViewController {
    
    
    //MARK: - Private Properties
    
    private var urlValue = ""
    private var numberFacts: NumberFacts?
    private var dateValue = ""
    private var textFieldValue = ""
    private var type = "trivia"
    
    private var urlName: String {
        get {
            "http://numbersapi.com/\(urlValue)/\(type)?json"
        }
    }
    
    
    
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var factLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        hideKeyboard()
        addDoneButton()
        
        datePicker.isHidden = true
        textField.isHidden = false
    }
    
    //MARK: - IBActions
    
    @IBAction func getButtonPressed(_ sender: Any) {
        
        
        if textField.text != "" || datePicker.isHidden == false {
            fetchData()
        } else {
            alertNotification(title: "Error!", message: "Type some number")
        }
    }
    
    //MARK: - Data Transfer
    
    @IBAction func unwindDate(for segue: UIStoryboardSegue) {
        guard let mainVC = segue.destination as? MainViewController else { return }
        mainVC.type = "date"
        mainVC.datePicker.isHidden = false
        mainVC.textField.isHidden = true
        mainVC.titleLabel.text = "Enter some date (Year doesn't matter)"
        mainVC.textField.text = ""
        mainVC.infoLabel.text = "Information about"
        mainVC.factLabel.text = ""
        
    }
    
    @IBAction func unwindTrivia(for segue: UIStoryboardSegue) {
        guard let mainVC = segue.destination as? MainViewController else { return }
        mainVC.type = "trivia"
        mainVC.titleLabel.text = "Enter some number:"
        clearView()
        
    }
    
    @IBAction func unwindMath(for segue: UIStoryboardSegue) {
        guard let mainVC = segue.destination as? MainViewController else { return }
        mainVC.type = "math"
        mainVC.titleLabel.text = "Enter some number:"
        clearView()
    }
    
    @IBAction func unwindYear(for segue: UIStoryboardSegue) {
        guard let mainVC = segue.destination as? MainViewController else { return }
        mainVC.type = "year"
        mainVC.titleLabel.text = "Enter some year:"
        clearView()
        
    }
    
}


//MARK: - Networking (Need move to NetworkManager)

extension MainViewController {
    
    private func fetchData() {
        
        if datePicker.isHidden == true {
            textFieldValue = textField.text ?? ""
            urlValue = textFieldValue
        } else {
            getDate()
            urlValue = dateValue
        }
        
        
        
        NetworkManager.shared.fetchData(from: urlName) { numberAndFacts in
            self.numberFacts = numberAndFacts
            
            DispatchQueue.main.async {
                self.factLabel.text = self.numberFacts?.text
                
                if self.datePicker.isHidden == true {
                    self.infoLabel.text = "A \(numberAndFacts.type ?? "") fact for \(String(numberAndFacts.number ?? 0))"
                } else {
                    self.infoLabel.text = "A \(numberAndFacts.type ?? "") fact for \(self.dateValue)/\(String(numberAndFacts.year ?? 0))"
                }
            }
            
        }
        
    }
    
}

// MARK: - keyboard settings
extension MainViewController {
    private func hideKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        
        textField.inputAccessoryView = toolBar
        
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
}

//MARK: - Extentions

extension MainViewController {
    private func clearView(){
        datePicker.isHidden = true
        textField.isHidden = false
        factLabel.text = ""
        infoLabel.text = "Information about"
        textField.text = ""
    }
    
    private func getDate() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month], from: self.datePicker.date)
        if let day = components.day, let month = components.month{
            let day = String(day)
            let month = String(month)
            
            dateValue = "\(month)/\(day)"
        }
    }
    
    private func alertNotification(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        let okAction = UIAlertAction(title: "ok", style: .cancel)
        alert.addAction(okAction)
    }
    
}
