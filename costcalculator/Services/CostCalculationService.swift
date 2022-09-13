//
//  CostCalculationService.swift
//  costcalculator
//
//  Created by eShifa on 08/09/2022.
//

import Foundation

// MARK : Function Prototype of service class
protocol CostCalculationService {
    var delegate  : CostCalculationViewModel {get}
    func requiredValidation(serialNumberTxt : String, currentReadingTxt : String)
    func dataValidation(currentReading: String)
    func dataValidation(serialNumber : String)
    func dataValidation(serialNumber : String, currentReading: String)
    func billCalculator(calculationModel : CostCalculationModel)
    func saveData(serialNumber : String, currentReading: String)
}

// MARK : Cost Calculation Serivce
class CostCalculationServiceDelegate : CostCalculationService {
    
    private final let slabTabe  = [
        ["range": 1...100 , "rate": 5],
        ["range": 101...500, "rate": 8],
        ["range": 501...Int.max, "rate": 10]
    ]
    
    private final var history : [HistoryModel] = [
        HistoryModel(serialNumber : "1234567890", units : 5, cost: 25),
    ]
    private final var lastReading : HistoryModel? = nil
    private final var totalCalculatedBill : Int = 0
    var delegate: CostCalculationViewModel
    
    init(delegate : CostCalculationViewModel) {
        self.delegate = delegate
    }
    
    private final func validateSerialNumber(serialNumber: String) -> (isValid: Bool,errorFields: (fieldName: String, inputValue : String)?){
        do {
            self.delegate.showHistory(historyValues: [])
            self.lastReading = nil
            self.totalCalculatedBill = 0
            let value = try serialNumber.validatedText(validationType: .alphanumeric)
            if(value.count < 10){
                self.delegate.handleSerialNumber(value: CustomMessages.serialNumber.localized())
                return (false, (fieldName: "SerialNumber", inputValue: CustomMessages.serialNumber.localized()))
            }else{
                let historyOfSerialNumber = filterArray(serialNumber: serialNumber)
                self.lastReading = historyOfSerialNumber.last
                self.delegate.showHistory(historyValues: historyOfSerialNumber)
                return (true, nil)
            }
        } catch let er as ValidationError{
            self.delegate.handleSerialNumber(value: er.localizedDescription)
            return (false, (fieldName: "SerialNumber", inputValue: er.message))
        }catch{
            self.delegate.handleSerialNumber(value: CustomMessages.serialNumber.localized())
            return (false, (fieldName: "SerialNumber", inputValue: CustomMessages.serialNumber.localized()))
        }
    }
    
    private final func filterArray(serialNumber: String)-> [HistoryModel]{
        
        return self.history.filter{$0.serialNumber == serialNumber}.last(count: 3)
    }
    
    private final func validateCurrentReading(currentReading: String) -> (isValid : Bool,errorFields: (fieldName: String, inputValue : String)?){
        do {
            let reading = try currentReading.validatedText(validationType: .positiveNumber)
            if(reading.isInt && (Int(reading) ?? 0) > (lastReading?.units ?? 0)){
                return (true,  nil)
            }else{
                self.delegate.handleCurrentReading(value: CustomMessages.currentReading.localized())
                return (false, (fieldName: "CurrentReading", inputValue: CustomMessages.currentReading.localized()))
            }
            
        }catch let er as ValidationError{
            self.delegate.handleCurrentReading(value: er.message)
            return (false, (fieldName: "CurrentReading", inputValue: er.localizedDescription))
        }catch{
            self.delegate.handleCurrentReading(value: CustomMessages.currentReading.localized())
            return (false, (fieldName: "CurrentReading", inputValue: CustomMessages.currentReading.localized()))
        }
    }
    
    private final func calulateBill(index : Int, units : Int){
        
        var bill : [CostCalculationModel] = []
        //Total Units Consumed on each Iteration
        var breakdownOfUnits = 0
        //Total Bill Sumup
        var totalBill : Int = 0
        
        for i in (0...index){
            //Current Iteration Data
            let maxValue = ((slabTabe[i]["range"]) as? ClosedRange)?.upperBound ?? 0
            let minValue = ((slabTabe[i]["range"]) as? ClosedRange)?.lowerBound ?? 0
            let rate = ((slabTabe[i]["rate"]) as? Int) ?? 0
            
            // Units to be consumed in current Itteration
            let canConsumedUnit =  (i != (slabTabe.count - 1)) ? ((maxValue - minValue) + 1) : units - breakdownOfUnits
            var unitToBeConsumed = 0
            unitToBeConsumed = (canConsumedUnit > units) ? (units - breakdownOfUnits) : (units - canConsumedUnit == 0) ? units : (canConsumedUnit > units - breakdownOfUnits) ? (units - breakdownOfUnits) : canConsumedUnit
            let cost = rate * unitToBeConsumed
            totalBill = totalBill + cost
            bill.append(CostCalculationModel(serialNumber : "\(unitToBeConsumed)x\(rate)", value: cost))
            breakdownOfUnits = breakdownOfUnits + unitToBeConsumed
            
        }
        if(bill.count > 0){
            bill.append(CostCalculationModel(serialNumber: "Total", value: totalBill))
            self.totalCalculatedBill = totalBill
            self.delegate.showBillWithBreakdown(billBreakDown: bill)
        }
    }
    
    func requiredValidation(serialNumberTxt: String, currentReadingTxt: String) {
        let requireFileds = Validation.shared.validate(values: (type: ValidationType.require, inputValue: serialNumberTxt, fieldName: "SerialNumber"),(type: ValidationType.require, currentReadingTxt, fieldName: "CurrentReading"))
        switch requireFileds {
        case .success:
            self.delegate.requireSuccess()
        case .failure(_, let fields):
            var fieldsArr :  [HandleUIErrorModel] = []
            for field in fields {
                if(field.contains("CurrentReading")){
                    fieldsArr.append(HandleUIErrorModel(key: "CurrentReading", value: CustomMessages.emptySerialNumber.localized()))
                }
                if(field.contains("SerialNumber")){
                    fieldsArr.append(HandleUIErrorModel(key: "SerialNumber", value: CustomMessages.emptyCurrentReading.localized()))
                }
            }
            self.delegate.handle(errorFields: (fieldsArr))
        }
    }
    
    func dataValidation(serialNumber: String) {
        let _ = validateSerialNumber(serialNumber: serialNumber)
    }
    
    func dataValidation(currentReading: String) {
        let _ = validateCurrentReading(currentReading: currentReading)
    }
    
    func dataValidation(serialNumber : String, currentReading: String) {
        let isValidSerial = validateSerialNumber(serialNumber: serialNumber)
        let isValidCurrentReading = validateCurrentReading(currentReading: currentReading)
        if(isValidSerial.isValid && isValidCurrentReading.isValid){
            self.delegate.validationSuccess(serialNumber: serialNumber, currentReading: currentReading)
        }
    }
    
    func billCalculator(calculationModel : CostCalculationModel){
        let unitForCalulation = (lastReading?.units ?? 0) == 0 ?  calculationModel.value : calculationModel.value - (lastReading?.units ?? 0)
        let index = slabTabe.firstIndex(where: {($0["range"] as? ClosedRange)?.contains(unitForCalulation) ?? false})
        if(index != nil){
            calulateBill(index: index!, units: unitForCalulation)
        }
    }
    
    func saveData(serialNumber : String, currentReading: String) {
        let data = HistoryModel(serialNumber:serialNumber, units: (Int(currentReading) ?? 0), cost: self.totalCalculatedBill)
        self.history.append(data)
        self.delegate.success()
    }
    
}
