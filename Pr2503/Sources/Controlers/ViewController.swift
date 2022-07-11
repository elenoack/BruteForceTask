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
    @IBOutlet weak var resertButton: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
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
    var queue = DispatchQueue.global(qos: .utility)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.delegate = self
    }
    
    //MARK: - Actions
    
    @IBAction func onBut(_ sender: Any) {
                isBlack.toggle()
    }
    
    @IBAction func cheakPassword(_ sender: Any) {
        if passwordTextField.text.isEmptyOrNil  {
            imageView.image = UIImage(named: "safeDeposit")
            queue.async {
                self.bruteForce(passwordToUnlock: self.passwordTextField.text ?? "")
            }
            label.text = nil
        } else {
            passwordTextField.isSecureTextEntry = false
            queue.async {
                self.bruteForce(passwordToUnlock: self.passwordTextField.text ?? "")
            }
            view.endEditing(true)
            imageView.image = UIImage(named: "safeDepositOpen")
            passwordTextField.text = nil
        }
    }
    
    @IBAction func reset(_ sender: Any) {
        view.endEditing(true)
        imageView.image = UIImage(named: "safeDeposit")
        passwordTextField.text = nil
        label.text = "Your password not been hacked"
        label.textColor = .systemGreen
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }
        
        var password: String = ""
        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            DispatchQueue.main.async {
                self.label.text = "Your password is too easy to guess: \(password)!"
            }
        }
        print(password)
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


//MARK: - Private

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

