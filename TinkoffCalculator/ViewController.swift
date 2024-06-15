//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Dorogov on 12.05.2024.
//

import UIKit

enum CalculationError: Error {
    case dividedByZero
}

enum Operation: String {
    case add = "+"
    case substract = "-"
    case multiply = "x"
    case divide = "/"
    
    func calculate(_ number1: Double, _ number2: Double) throws -> Double {
        switch self {
        case .add:
            return number1 + number2
        case .substract:
            return number1 - number2
        case .multiply:
            return number1 * number2
        case .divide:
            if number2 == 0 {
                throw CalculationError.dividedByZero
            }
            return number1 / number2
        }
    }
}

enum CalculationHistoryItem {
    case number(Double)
    case operation(Operation)
}

class ViewController: UIViewController {
    
    var calculationHistory: [CalculationHistoryItem] = []
    var calculations: [Calculation] = []
    
    let calculationHistoryStorage = CalculationHistoryStorage()
    
    
    var isCalculateButtonPressed = false
    var isCalculateFuncCalled = false
    var resultForHistory: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetTextLabel()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistoryStorage.loadHistory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // ленивое свойство (в отличии от обычного) устанавливает своё значение только после обращения к нему и в дальнейшем это значение не изменяется
    lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.usesGroupingSeparator = false
        numberFormatter.locale = Locale(identifier: "ru_RU")
        numberFormatter.numberStyle = .decimal
        return numberFormatter
    }()
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        if isCalculateButtonPressed == true {
            label.text = "0"
            isCalculateButtonPressed = false
        }
        
        guard let buttonText = sender.currentTitle else { return }
        
        if buttonText == "," && label.text?.contains(",") == true {
            return
        }
        
        if buttonText == "," && label.text == "0" || buttonText == "," && label.text == "Ошибка" {
            label.text = "0,"
        } else if label.text == "Ошибка" {
            label.text = buttonText
        } else if label.text == "0" {
            label.text = buttonText
        } else {
            label.text?.append(buttonText)
        }
    }
    
    @IBAction func operationButtonPressed(_ sender: UIButton) {
        guard
            let buttonText = sender.currentTitle,
            let buttonOperation = Operation(rawValue: buttonText)
            else { return }
        guard
            let labelText = label.text, // конвертируем текстлэйбл в число
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        calculationHistory.append(.operation(buttonOperation))
  
        resetTextLabel()
    }
    
    @IBAction func clearButtonPressed() {
        calculationHistory.removeAll()
        resetTextLabel()
    }
    
    @IBAction func calculateButtonPressed() {
        
        isCalculateButtonPressed = true
        isCalculateFuncCalled = true
    
        guard
            let labelText = label.text, // конвертируем текстлэйбл в число
            let labelNumber = numberFormatter.number(from: labelText)?.doubleValue
            else { return }
        
        calculationHistory.append(.number(labelNumber))
        
        do {
            let result = try calculate()
            
            label.text = numberFormatter.string(from: NSNumber(value: result))
            let newCalculation = Calculation(expression: calculationHistory, result: result)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
            
      //      resultForHistory = String(result)
       //     resultForHistory = resultForHistory.components(separatedBy: ".")[0]
            
        } catch {
            label.text = "Ошибка"
        }
        calculationHistory.removeAll()
    }
    
    @IBAction func showCalculationsList(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let calculationsListVC = sb.instantiateViewController(identifier: "CalculationsListViewController")
        if let vc = calculationsListVC as? CalculationsListViewController {
            vc.calculations = calculations
            
//            if isCalculateFuncCalled && resultForHistory != "" {
//                vc.result = resultForHistory
//            } else if isCalculateFuncCalled {
//                vc.calculations = calculations
//            } else {
//                vc.result = "NoData"
//            }
        }
        
        navigationController?.pushViewController(calculationsListVC, animated: true)
    }
    
    @IBOutlet var label: UILabel!
    @IBOutlet var historyButton: UIButton!
    
    func calculate() throws -> Double {
        guard case .number(let firstNumber) = calculationHistory[0] else { return 0 }
        var currentResult = firstNumber
        for index in stride(from: 1, to: calculationHistory.count - 1, by: 2) {
            guard
                case .operation(let operation) = calculationHistory[index],
                case .number(let number) = calculationHistory[index + 1]
                else { break }
            
            currentResult = try operation.calculate(currentResult, number)
        }
        return currentResult
    }

    func resetTextLabel() {
        label.text = "0"
    }
}

