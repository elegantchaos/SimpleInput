// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

public struct SimpleInput {
    public typealias Validator = (String) -> Bool
    public enum Button {
        case normal(String,(String) -> (), Validator? = nil)
        case destructive(String, (String) -> (), Validator? = nil)
        case cancel(String = "Cancel", () -> () = { })
        
        func action(field: UITextField? = nil, completion: @escaping () -> ()) -> UIAlertAction {
            switch self {
                case .normal(let title, let action, _):
                    return UIAlertAction(title: NSLocalizedString(title, comment: "button title"), style: .default) { _ in
                        action(field?.text ?? "")
                        completion()
                    }
                    
                case .destructive(let title, let action, _):
                    return UIAlertAction(title: NSLocalizedString(title, comment: "button title"), style: .destructive) { _ in
                        action(field?.text ?? "")
                        completion()
                    }

                case .cancel(let title, let action):
                    return UIAlertAction(title: NSLocalizedString(title, comment: "button title"), style: .cancel) { _ in
                        action()
                        completion()
                    }
            }

        }
    }

    public struct Field {
        let placeholder: String
        let autocapitalizationType: UITextAutocapitalizationType
        let autocorrectionType: UITextAutocorrectionType
        let spellCheckingType: UITextSpellCheckingType
        let smartQuotesType: UITextSmartQuotesType
        let smartDashesType: UITextSmartDashesType
        let smartInsertDeleteType: UITextSmartInsertDeleteType
        let keyboardType: UIKeyboardType
        let keyboardAppearance: UIKeyboardAppearance
        let returnKeyType: UIReturnKeyType
        let enablesReturnKeyAutomatically: Bool
        let isSecureTextEntry: Bool
        let textContentType: UITextContentType?
        
        let validator: Validator?
        
        public init(
            placeholder: String = "",
            autocapitalizationType: UITextAutocapitalizationType = .sentences,
            autocorrectionType: UITextAutocorrectionType = .default,
            spellCheckingType: UITextSpellCheckingType = .default,
            smartQuotesType: UITextSmartQuotesType = .default,
            smartDashesType: UITextSmartDashesType = .default,
            smartInsertDeleteType: UITextSmartInsertDeleteType = .default,
            keyboardType: UIKeyboardType = .default,
            keyboardAppearance: UIKeyboardAppearance = .default,
            returnKeyType: UIReturnKeyType = .default,
            enablesReturnKeyAutomatically: Bool = false,
            isSecureTextEntry: Bool = false,
            textContentType: UITextContentType? = nil,
            validator: Validator? = nil
            ) {
            self.placeholder = NSLocalizedString(placeholder, comment: "input placeholder")
            self.autocapitalizationType = autocapitalizationType
            self.autocorrectionType = autocorrectionType
            self.spellCheckingType = spellCheckingType
            self.smartQuotesType = smartQuotesType
            self.smartDashesType = smartDashesType
            self.smartInsertDeleteType = smartInsertDeleteType
            self.keyboardType = keyboardType
            self.keyboardAppearance = keyboardAppearance
            self.returnKeyType = returnKeyType
            self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
            self.isSecureTextEntry = isSecureTextEntry
            self.textContentType = textContentType
            self.validator = validator
        }
    }
    
    public init(title: String, message: String, field: Field, buttons: [Button]) {
        self.title = NSLocalizedString(title, comment: "input title")
        self.message = NSLocalizedString(message, comment: "input message")
        self.field = field
        self.buttons = buttons
    }
    
    public let title: String
    public let message: String
    public let field: Field
    public let buttons: [Button]
}


final class Coordinator: NSObject, UITextFieldDelegate {
    typealias ButtonMap = [Int: (String) -> Bool]
    
    var alert: UIAlertController?
    var validator: SimpleInput.Validator?
    var buttonMap: ButtonMap = [:]

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let existing = textField.text ?? ""
        for (index, validator) in buttonMap {
            alert!.actions[index].isEnabled = validator(existing)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let validator = validator else { return true }
        
        let existing = textField.text ?? ""
        let modified = (existing as NSString).replacingCharacters(in: range, with: string)
        
        for (index, validator) in buttonMap {
            alert!.actions[index].isEnabled = validator(modified)
        }

        return validator(modified)
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


extension UIAlertController {
    convenience init(input: SimpleInput, coordinator: Coordinator, completion: @escaping () -> ()) {
        self.init(title: input.title, message: input.message, preferredStyle: .alert)
        addTextField {
            let settings = input.field
            $0.placeholder = settings.placeholder
            $0.delegate = coordinator
            $0.autocapitalizationType = settings.autocapitalizationType
            $0.autocorrectionType = settings.autocorrectionType
            $0.spellCheckingType = settings.spellCheckingType
            $0.smartQuotesType = settings.smartQuotesType
            $0.smartDashesType = settings.smartDashesType
            $0.smartInsertDeleteType = settings.smartInsertDeleteType
            $0.keyboardType = settings.keyboardType
            $0.keyboardAppearance = settings.keyboardAppearance
            $0.returnKeyType = settings.returnKeyType
            $0.enablesReturnKeyAutomatically = settings.enablesReturnKeyAutomatically
            $0.isSecureTextEntry = settings.isSecureTextEntry
            if let type = settings.textContentType {
                $0.textContentType = type
            }
        }

        for button in input.buttons {
            let action = button.action(field: self.textFields?.first, completion: completion)
            addAction(action)
        }
    }
}

class EmptyViewController: UIViewController {
}

struct AlertHostView: UIViewControllerRepresentable{
    @Binding var input: SimpleInput?
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: Context) -> EmptyViewController {
        return EmptyViewController()
    }
    
    func updateUIViewController(_ controller: EmptyViewController, context: Context) {
        let coordinator = context.coordinator
        if let input = input, controller.presentedViewController == nil {
            let alert = UIAlertController(input: input, coordinator: coordinator) {
                coordinator.reset()
                self.input = nil
            }

            coordinator.setup(alert: alert, input: input)
            controller.present(alert, animated: true)

        } else if controller.presentedViewController != nil, input == nil {
            context.coordinator.alert?.dismiss(animated: true)
            coordinator.reset()
        }
    }
}


struct SimpleInputModifier: ViewModifier {
    @Binding var input: SimpleInput?
    
    func body(content: Content) -> some View {
        content
            .background(AlertHostView(input: $input))
    }
}

extension View {
    public func simpleInput(_ input: Binding<SimpleInput?>) -> some View {
        self
            .modifier(SimpleInputModifier(input: input))
    }
}
