//
//  LoginViewModel.swift
//  RxSwift-Login-Practice
//
//  Created by 大西玲音 on 2021/11/12.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    
    private let disposeBag = DisposeBag()
    private let messageTextSubject = BehaviorSubject<String>(value: "")
    private let loginEventSubject = PublishSubject<Void>()
    
    struct Input {
        let emailText: Driver<String>
        let passwordText: Driver<String>
        let loginButton: Signal<Void>
    }
    
    struct Output {
        let messageText: Driver<String>
        let messageIsHidden: Driver<Bool>
        let loginButtonIsEnabled: Driver<Bool>
        let loginIsSuccessful: Driver<Void>
    }
    
    func transform(_ input: Input) -> Output {
        handleValidInputMessage(input)
        handleLoginButtonTap(input)
        return Output(
            messageText: messageText,
            messageIsHidden: messageIsEmpty,
            loginButtonIsEnabled: inputIsValid(input),
            loginIsSuccessful: loginIsSuccessful
        )
    }
    
}

private extension LoginViewModel {
    
    var messageText: Driver<String> {
        messageTextSubject.asDriver(onErrorJustReturn: "")
    }
    
    var messageIsEmpty: Driver<Bool> {
        messageText.map { $0.isEmpty }
    }
    
    var loginIsSuccessful: Driver<Void> {
        loginEventSubject.asDriver(onErrorDriveWith: .never())
    }
    
    func inputIsValid(_ input: Input) -> Driver<Bool> {
        Observable
            .combineLatest(
                input.emailText.asObservable(),
                input.passwordText.asObservable()
            )
            .map { !$0.isEmpty && !$1.isEmpty }
            .asDriver(onErrorJustReturn: false)
    }
    
    func handleValidInputMessage(_ input: Input) {
        Observable
            .combineLatest(
                input.emailText.asObservable(),
                input.passwordText.asObservable()
            )
            .map { emailText, passwordText in
                if emailText.isEmpty {
                    return "Please provide an e-mail."
                } else if !emailText.isValidEmail {
                    return "E-mail address is not valid."
                } else if passwordText.isEmpty {
                    return "Please provide an password."
                } else {
                    return ""
                }
            }
            .subscribe(messageTextSubject)
            .disposed(by: disposeBag)
    }
    
    func handleLoginButtonTap(_ input: Input) {
        let isSuccessed = true
        let result = input.loginButton.asObservable()
            .withLatestFrom(
                Observable.combineLatest(
                    input.emailText.asObservable(),
                    input.passwordText.asObservable()
                )
            )
            .flatMapLatest { email, pass in
                return Single<String>.create { observer in
                    if isSuccessed {
                        observer(.success("成功"))
                    } else {
                        observer(.failure(APIError.invalid))
                    }
                    return Disposables.create()
                }
            }
            .share()
        result
            .map { _ in "" }
            .subscribe(messageTextSubject)
            .disposed(by: disposeBag)
        result
            .map { _ in }
            .subscribe(loginEventSubject)
            .disposed(by: disposeBag)
    }
    
}

private extension String {
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
}

enum APIError: Error {
    case invalid
}
