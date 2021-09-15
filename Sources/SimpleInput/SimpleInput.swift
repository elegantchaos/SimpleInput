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


struct SimpleInputModifier: ViewModifier {
    @Binding var input: SimpleInput?
    
    func body(content: Content) -> some View {
        content
            .background(HostView(input: $input))
    }
}

extension View {
    public func simpleInput(_ input: Binding<SimpleInput?>) -> some View {
        self
            .modifier(SimpleInputModifier(input: input))
    }
}
