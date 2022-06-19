//
//  ViewController.swift
//  InterestingNumbers
//
//  Created by Daniil Klimenko on 18.06.2022.
//

import UIKit

class MainViewController: UIViewController {
 
    
//MARK: - Properties
    
    var dateValue = ""
    var textFieldValue = ""
    var type = "trivia"
    
    
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
        
        if textField.text != "" {
            fetchFact()
        } else if datePicker.isHidden == false {
            fetchFact()
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
    func fetchFact() {
        
        var urlValue = ""
        
        if datePicker.isHidden == true {
            textFieldValue = textField.text ?? ""
            urlValue = textFieldValue
        } else {
            getDate()
            urlValue = dateValue
        }
        
        let url = "http://numbersapi.com/\(urlValue)/\(type)?json"
        
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No description")
                return
            }
            
            do {
                let someInfo = try JSONDecoder().decode(NumberFacts.self, from: data)
                print(someInfo.text ?? "Erro. No text")
                
                DispatchQueue.main.async {
                    self.factLabel.text = someInfo.text
                    
                    if self.datePicker.isHidden == true {
                        self.infoLabel.text = "A \(someInfo.type ?? "") fact for \(String(someInfo.number ?? 0))"
                    } else {
                        self.infoLabel.text = "A \(someInfo.type ?? "") fact for \(self.dateValue)/\(String(someInfo.year ?? 0))"
                    }
                }
                
            } catch let error {
                print(error)
            }
            
        }.resume()
        
        
    }
}

// MARK: - keyboard settings
extension MainViewController {
    func hideKeyboard() {
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
    func clearView(){
        datePicker.isHidden = true
        textField.isHidden = false
        factLabel.text = ""
        infoLabel.text = "Information about"
        textField.text = ""
    }
    
    func getDate() {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.month], from: self.datePicker.date)
        if let day = components.day, let month = components.month{
            let day = String(day)
            let month = String(month)
            
            dateValue = "\(month)/\(day)"
        }
    }
    
    func alertNotification(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        let okAction = UIAlertAction(title: "ok", style: .cancel)
        alert.addAction(okAction)
    }
    
}
