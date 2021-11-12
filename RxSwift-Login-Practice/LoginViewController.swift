//
//  LoginViewController.swift
//  RxSwift-Login-Practice
//
//  Created by 大西玲音 on 2021/11/12.
//

import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var loginButton: UIButton!
    
    private let disposeBag = DisposeBag()
    private let loginViewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
        
    }
    
    private func setupBindings() {
        let input = LoginViewModel.Input(
            emailText: emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: passwordTextField.rx.text.orEmpty.asObservable(),
            loginButton: loginButton.rx.tap.asObservable()
        )
        
        let output = loginViewModel.transform(input)
        
        output.loginButtonIsEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.messageIsHidden
            .drive(messageLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.messageText
            .drive(messageLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.loginIsSuccessful
            .drive(onNext: presentMain)
            .disposed(by: disposeBag)
    }
    
    private func presentMain() {
        // 画面遷移
    }
    
}

