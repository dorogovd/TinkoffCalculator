//
//  ViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Dorogov on 12.05.2024.
//

import UIKit

protocol LongPressViewProtocol {
    var shared: UIView { get }
    
    func startAnimation()
    func stopAnimation()
}

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
    
    private let alertView: AlertView = {
        let screenBounds = UIScreen.main.bounds
        let alertHeight: CGFloat = 100
        let alertWidth: CGFloat = screenBounds.width - 40
        let x: CGFloat = screenBounds.width / 2 - alertWidth / 2
        let y: CGFloat = screenBounds.height / 2 - alertHeight / 2
        let alertFrame = CGRect(x: x, y: y, width: alertWidth, height: alertHeight)
        let alertView = AlertView(frame: alertFrame)
        return alertView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        resetTextLabel()
        historyButton.accessibilityIdentifier = "historyButton"
        calculations = calculationHistoryStorage.loadHistory()
        
        resetTextLabel()
        view.addSubview(alertView)
        alertView.alpha = 0
        alertView.alertText = "Вы нашли пасхалку!"
        
        view.subviews.forEach {
            if type(of: $0) == UIButton.self { // проверяем является ли вью кнопкой
                $0.layer.cornerRadius = 45
            }
        }
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
        
        if label.text == "3,141592" {
            animateAlert()
        }
        
        sender.animateTap()
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
        resetTextLabel() // расхождение в нейминге с проектом
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
            let newCalculation = Calculation(expression: calculationHistory, result: result, date: Date.now)
            calculations.append(newCalculation)
            calculationHistoryStorage.setHistory(calculation: calculations)
            
      //      resultForHistory = String(result)
       //     resultForHistory = resultForHistory.components(separatedBy: ".")[0]
            
        } catch {
            label.text = "Ошибка"
            label.shake()
        }
        calculationHistory.removeAll()
        animateBackground()
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
    
    func animateAlert() { // анимация
        
        if !view.contains(alertView) {
            alertView.alpha = 0
            alertView.center = view.center
            view.addSubview(alertView)
        }
        UIView.animateKeyframes(withDuration: 2.0, delay: 0.5) {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.alertView.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                var newCenter = self.label.center
                newCenter.y -= self.alertView.bounds.height
                self.alertView.center = newCenter
            }
        
//        UIView.animate(withDuration: 0.5) {
//            self.alertView.alpha = 1
//        } 
//    completion: { (_) in // блок комплишн выполняется после анимации
//            UIView.animate(withDuration: 0.5) {
//                var newCenter = self.label.center // изменене положения лейбла
//                newCenter.y -= self.alertView.bounds.height
//                self.alertView.center = newCenter
//            }
        //        }
//        UIView.animate(withDuration: 0.5, delay: 0.5) {
//            var newCenter = self.label.center // изменене положения лейбла
//            newCenter.y -= self.alertView.bounds.height
//            self.alertView.center = newCenter
        }
    }
    
    func animateBackground() {
        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.duration = 1
        animation.fromValue = UIColor.white.cgColor
        animation.toValue = UIColor.blue.cgColor
        
        view.layer.add(animation, forKey: "backgroundColor")
        view.layer.backgroundColor = UIColor.blue.cgColor
    }
}

extension UILabel {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 5
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: center.x - 5, y: center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: center.x + 5, y: center.y))
        
        layer.add(animation, forKey: "position")
    }
}

extension UIButton {
    
    func animateTap() {
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1, 0.9, 1]
        scaleAnimation.keyTimes = [0, 0.2, 1]
        
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        opacityAnimation.values = [0.4, 0.8, 1]
        opacityAnimation.keyTimes = [0, 0.2, 1]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.5
        animationGroup.animations = [scaleAnimation, opacityAnimation]
        
        layer.add(animationGroup, forKey: "groupAnimation")
    }
}
