//
//  CalculationsListViewController.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Dorogov on 19.05.2024.
//

import UIKit

class CalculationsListViewController: UIViewController {
    
    var calculations: [Calculation] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor.systemGray5 // цвет фона tableView
        let tableHeaderView = UIView()
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 30) // отступ сверху tableView
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1)) // заполняем сплошным цветом tableView внизу
        
        let nib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "HistoryTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

private func expressionToString(_ expression: [CalculationHistoryItem]) -> String {
    var result = ""
    
    for operand in expression {
        switch operand {
        case let .number(value):
            result += String(value) + " "
        case let .operation(value):
            result += value.rawValue + " "
        }
        }
    return result
    }
    
    private func getCurrentDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter.string(from: date)
    }
}

extension CalculationsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90.0
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getCurrentDate(calculations[section].date)
    }
    
}

extension CalculationsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return calculations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTableViewCell", for: indexPath) as! HistoryTableViewCell
        let historyItem = calculations[indexPath.section]
        cell.configure(with: expressionToString(historyItem.expression), result: String(historyItem.result))
        return cell
    }
}
