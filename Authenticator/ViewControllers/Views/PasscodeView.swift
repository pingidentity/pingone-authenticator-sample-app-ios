//
//  PasscodeView.swift
//  Authenticator
//
//  Copyright © 2020 Ping Identity. All rights reserved.
//

import UIKit
import PingOne

protocol PasscodeViewDelegateProtocol: class {
    func didAskForPasscode()
    func didTappedView()
}

class PasscodeView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var passcodeTitleLbl: UILabel!
    @IBOutlet weak var passcodeNumLbl: UILabel!
    @IBOutlet weak var verticalProgressView: VerticalProgressView!
    
    weak var delegate: PasscodeViewDelegateProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTappedView))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PasscodeView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        
        verticalProgressView.delegate = self
        
        passcodeNumLbl.text = nil
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    func update(passcode: OneTimePasscodeInfo) {
        passcodeNumLbl.text = passcode.passcode
        verticalProgressView.timeWindow = passcode.timeWindowSize
        passcodeNumLbl.addCharacterSpacing(kernValue: 5)
        verticalProgressView.animate(with: passcode.timeWindowSize)
    }
    
    @objc func didTappedView(_ sender: Any) {
        UIPasteboard.general.string = passcodeNumLbl.text
        delegate?.didTappedView()
    }

    @objc func appWillEnterForeground() {
        if passcodeNumLbl.text != nil {
            delegate?.didAskForPasscode()
        }
    }
}

extension PasscodeView: VerticalProgressViewDelegateProtocol{
    func didFinishAnimation() {
        delegate?.didAskForPasscode()
    }
    
    func didAnimationColorChange(to color: UIColor){
        self.passcodeNumLbl.textColor = color
    }
}
