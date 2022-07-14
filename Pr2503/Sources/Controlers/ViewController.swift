//
//  ViewController.swift
//  Pr2503
//
//  Created by Elena Noack on 11.07.22.
//

import UIKit

class ViewController: UIViewController {
    // MARK: - Outlets
    
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var checkPasswordButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Properties
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .darkGray
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    var password = String()
    private var hasPasswordData: Bool { !(passwordTextField?.text).isEmptyOrNil }
    var isWork = false
    let queue = DispatchQueue(label: Strings.queueLabel, qos: .utility)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupButton()
    }
    
    //MARK: - Settings
    
    private func setupView() {
        overrideUserInterfaceStyle = .light
        passwordTextField.delegate = self
        activityIndicator.isHidden = true
    }
    
    private func setupButton() {
        addStyle([
            checkPasswordButton,
            changeColorButton,
            resetButton
        ])
        
        checkPasswordButton.tintColor = .orange
        changeColorButton.tintColor = .systemBlue
        resetButton.tintColor = .systemBlue
    }
    
    //MARK: - Actions
    
    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    @IBAction func checkPassword(_ sender: Any) {
        isWork = true
        password = passwordTextField.text ?? ""
        if hasPasswordData {
            self.view.endEditing(true)
            queue.async {
                self.bruteForce(passwordToUnlock: self.password)
            }
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        isWork = false
        view.endEditing(true)
        imageView.image = UIImage(named: Strings.imageSafeDeposit)
        passwordTextField.text = nil
        
        DispatchQueue.main.async {
            self.label.text = Strings.labelPasswordNotHacked
            self.label.textColor = .systemGreen
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.clean()
        }
    }
}

//MARK: - Private

extension ViewController {
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }
        isWork = true
        var password: String = ""
        
        let findPasswordWorkItem = DispatchWorkItem {
            self.label.textColor = .systemPink
            self.label.text = Strings.labelPassword + "\(password)"
            self.passwordTextField.isSecureTextEntry = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
        
        let resultPasswordWorkItem = DispatchWorkItem {
            self.label.textColor = .systemPink
            self.label.text = Strings.labelPasswordEasyGuess + "\(password)!"
            self.imageView.image = UIImage(named: Strings.imageSafeDepositOpen)
            self.passwordTextField.isSecureTextEntry = false
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
        
        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            
            if isWork {
                DispatchQueue.main.async(execute: findPasswordWorkItem)
            } else {
                break
            }
            print(password)
        }
        
        if isWork {
        DispatchQueue.main.async(execute: resultPasswordWorkItem)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.clean()
        }
    }
    
    func clean() {
        self.imageView.image = UIImage(named: Strings.imageSafeDeposit)
        self.label.text = ""
        passwordTextField.text = nil
    }
    
    func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }
    
    func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
        : Character("")
    }
    
    func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var string: String = string
        
        if string.count <= 0 {
            string.append(characterAt(index: 0, array))
        }
        
        else {
            string.replace(at: string.count - 1,
                           with: characterAt(index: (indexOf(character: string.last!, array) + 1) % array.count, array))
            
            if indexOf(character: string.last!, array) == 0 {
                string = String(generateBruteForce(String(string.dropLast()), fromArray: array)) + String(string.last!)
            }
        }
        return string
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        return updatedText.count <= 3
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == passwordTextField {
            textField.becomeFirstResponder()
        }
        return false
    }
}

// MARK: - Constants

extension ViewController {
    
    enum Strings {
        static let queueLabel = "brute"
        static let imageSafeDeposit = "safeDeposit"
        static let imageSafeDepositOpen = "safeDepositOpen"
        static let labelPasswordNotHacked = "Your password not been hacked!"
        static let labelPasswordEasyGuess = "Your password is too easy to guess "
        static let labelPassword = "Your password: "
    }
}

