// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import UIKit

final internal class Coordinator: NSObject {
    typealias ButtonMap = [Int: (String) -> Bool]
    
    var alert: UIAlertController?
    var validator: SimpleInput.Validator?
    var buttonMap: ButtonMap = [:]

    func validateButtons(for string: String) {
        for (index, validator) in buttonMap {
            alert!.actions[index].isEnabled = validator(string)
        }
    }
    
    func setup(alert: UIAlertController, input: SimpleInput) {
        var index = 0
        var map: ButtonMap = [:]
        for button in input.buttons {
            switch button {
                case .normal(_, _, let validator), .destructive(_, _, let validator):
                    map[index] = validator
                default:
                    break
            }
            index += 1
        }
        
        self.alert = alert
        self.validator = input.field.validator
        self.buttonMap = map
    }
    
    func reset() {
        alert = nil
        buttonMap = [:]
        validator = nil
    }
}

extension Coordinator: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        validateButtons(for: textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let existingText = (textField.text ?? "")
        let proposedText = (existingText as NSString).replacingCharacters(in: range, with: string)
        let textAllowed = validator?(proposedText) ?? true
        validateButtons(for: textAllowed ? proposedText : existingText)
        return textAllowed
    }
}
