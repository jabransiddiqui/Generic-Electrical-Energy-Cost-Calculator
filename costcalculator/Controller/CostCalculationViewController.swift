//
//  CostCalculationViewController.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import UIKit


class CostCalculationViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var txtSerialNumber : ACFloatingTextfield!
    @IBOutlet weak var txtCurrentReading : ACFloatingTextfield!
    @IBOutlet weak var historyStackView : UIStackView!
    @IBOutlet weak var historyStack : UIStackView!
    @IBOutlet weak var calcluationStackView : UIStackView!
    @IBOutlet weak var calcluationStack : UIStackView!
    
    // MARK: Variables
    var costCalculator: CostCalculationService?
    
    //MARK: Default Function
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.hideKeyboardWhenTappedAround()
        costCalculator = CostCalculationServiceDelegate(delegate: self)
        hideUIView()
        clearFields()
    }
    
    //MARK: Login Buton Action
    @IBAction func submitBtnTap(_ sender: UIButton) {
        self.view.endEditing(true)
        costCalculator?.requiredValidation(serialNumberTxt: self.txtSerialNumber.text ?? "", currentReadingTxt: self.txtCurrentReading.text ?? "")
    }
    
    //MARK: Login Buton Action
    @IBAction func saveBtnTap(_ sender: UIButton) {
        self.view.endEditing(true)
        costCalculator?.saveData(serialNumber: self.txtSerialNumber.text ?? "", currentReading: self.txtCurrentReading.text ?? "0")
    }
    
    //MARK: StackView UI
    func addUIStackView(value1: String,value2 : String) -> UIStackView {
        let stackView   = UIStackView()
        stackView.axis  = .horizontal
        stackView.distribution  = .equalSpacing
        stackView.spacing   = 15.0
        stackView.addArrangedSubview(addLabel(value: value1))
        stackView.addArrangedSubview(addLabel(value: value2))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
        
    }
    
    //MARK: Label UI
    func addLabel(value : String) -> UILabel{
        let textLabel = UILabel()
        textLabel.numberOfLines = 0
        textLabel.text  = value
        return textLabel
    }
    
    //MARK: Other Function
    
    func clearFields(){
        self.txtCurrentReading.text = ""
        self.txtSerialNumber.text = ""
    }
    
    func hideUIView(){
        self.historyStack.removeAllArrangedSubviews()
        self.historyStackView.isHidden = true
        self.calcluationStack.removeAllArrangedSubviews()
        self.calcluationStackView.isHidden = true
    }
    
    //Show error on Serial Number
    func showSerialNumberError(value : String){
        self.txtSerialNumber.showErrorWithText(errorText: value)
    }
    
    //Show error on Current Reading
    func showCurrentReadingError(value : String){
        self.txtCurrentReading.showErrorWithText(errorText: value)
    }
    
    func dataValidation(){
        self.costCalculator?.dataValidation(serialNumber: self.txtSerialNumber.text ?? "", currentReading: self.txtCurrentReading.text ?? "")
    }
    
}

// MARK: TextField
extension CostCalculationViewController : UITextFieldDelegate {
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        if textField == txtSerialNumber {
            let allowedCharacters = CharacterSet.alphanumerics
            let characterSet = CharacterSet(charactersIn: string)
            // Length Processing
            // Need to convert the NSRange to a Swift-appropriate type
            if let text = textField.text, let range = Range(range, in: text) {
                let proposedText = text.replacingCharacters(in: range, with: string)
                // Check proposed text length does not exceed max character count
                guard proposedText.count <= 10 else {
                    // Present alert if pasting text
                    // easy: pasted data has a length greater than 1; who copy/pastes one character?
                    if string.count > 1 {
                        // Pasting text, present alert so the user knows what went wrong
                        self.showSerialNumberError(value: CustomMessages.serialNumberCopyPaste.localized())
                    }
                    // Character count exceeded, disallow text change
                    return false
                }
            }
            return allowedCharacters.isSuperset(of: characterSet)
        }else if(textField == txtCurrentReading){
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }else{
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtSerialNumber {
            self.costCalculator?.dataValidation(serialNumber: self.txtSerialNumber.text ?? "")
        }else if(textField == self.txtCurrentReading){
            if(textField.text == ""){
                self.calcluationStack.removeAllArrangedSubviews()
                self.calcluationStackView.isHidden = true
            }
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.hideUIView()
        return true
    }
    
}

// MARK: Cost Calculation View Model
extension CostCalculationViewController : CostCalculationViewModel{
  
    func requireSuccess() {
        self.dataValidation()
    }
    
    func handle(errorFields: [HandleUIErrorModel]) {
        for field in errorFields {
            if field.key == "SerialNumber"{
                self.showSerialNumberError(value: field.value)
            }
            if field.key == "CurrentReading"{
                self.showCurrentReadingError(value: field.value)
            }
        }
    }
    
    func validationSuccess(serialNumber : String, currentReading: String) {
        let calculationModel = CostCalculationModel(serialNumber: serialNumber, value: Int(currentReading) ?? 0)
        self.costCalculator?.billCalculator(calculationModel: calculationModel)
    }
    
    func success() {
        self.clearFields()
        self.hideUIView()
        showAlert(withTitle: "Success", message: "Data saved successfully.")
    }
    
    func failure(error: Error) {
        
    }
    
    func handleSerialNumber(value : String){
        self.showSerialNumberError(value: value)
    }
    func handleCurrentReading(value : String){
        self.showCurrentReadingError(value: value)
    }
    
    func showHistory(historyValues: [HistoryModel]) {
        DispatchQueue.main.async {
            self.historyStack.removeAllArrangedSubviews()
            if(historyValues.isEmpty){
                self.historyStackView.isHidden = true
            }else{
                self.historyStackView.isHidden = false
                for histo in historyValues{
                    self.historyStack.addArrangedSubview(self.addUIStackView(value1: "\(histo.units)", value2: "\(histo.cost)"))
                }
            }
        }
    }
    
    func showBillWithBreakdown(billBreakDown: [CostCalculationModel]){
        DispatchQueue.main.async {
            self.calcluationStack.removeAllArrangedSubviews()
            if(billBreakDown.isEmpty){
                self.calcluationStackView.isHidden = true
            }else{
                self.calcluationStackView.isHidden = false
                for breakdown in billBreakDown{
                    self.calcluationStack.addArrangedSubview(self.addUIStackView(value1: breakdown.serialNumber, value2: "\(breakdown.value)"))
                }
            }
        }
    }
}

