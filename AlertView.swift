//
//  AlertView.swift
//  TinkoffCalculator
//
//  Created by Dmitrii Dorogov on 02.07.2024.
//

import UIKit

class AlertView: UIView {
    
    var alertText: String? {
        didSet { // код в дидсет вызывается при каждом свойства метода алерттекст
            label.text = alertText
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(label)
        backgroundColor = .red
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(hide))
        addGestureRecognizer(tap)
    }
    
    @objc private func hide() {
        removeFromSuperview()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
}
