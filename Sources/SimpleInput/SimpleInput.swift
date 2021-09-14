// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

extension UIAlertController {
    convenience init(input: SimpleInput, completion: @escaping () -> ()) {
        self.init(title: input.title, message: input.message, preferredStyle: .alert)
        addTextField {
            let settings = input.field
            $0.placeholder = settings.placeholder
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
            addAction(button.action(field: self.textFields?.first, completion: completion))
        }
    }
}

class EmptyViewController: UIViewController {
}

struct InputVC: UIViewControllerRepresentable{
    @Binding var input: SimpleInput?
    
    final class Coordinator {
        var alert: UIAlertController?
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: Context) -> EmptyViewController {
        return EmptyViewController()
    }
    
    func updateUIViewController(_ controller: EmptyViewController, context: Context) {
        let coordinator = context.coordinator
        if let input = input, controller.presentedViewController == nil {
            let alert = UIAlertController(input: input) {
                coordinator.alert = nil
                self.input = nil
            }

            coordinator.alert = alert
            controller.present(alert, animated: true)
        } else if controller.presentedViewController != nil, input == nil {
            context.coordinator.alert?.dismiss(animated: true)
            coordinator.alert = nil
        }
    }
}


public struct SimpleInput {
    public enum Button {
        case normal(String,(String) -> ())
        case destructive(String, (String) -> ())
        case cancel(String = "Cancel", () -> () = { })
        
        func action(field: UITextField? = nil, completion: @escaping () -> ()) -> UIAlertAction {
            switch self {
                case .normal(let title, let action):
                    return UIAlertAction(title: NSLocalizedString(title, comment: "button title"), style: .default) { _ in
                        action(field?.text ?? "")
                        completion()
                    }
                    
                case .destructive(let title, let action):
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
            textContentType: UITextContentType? = nil
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
            .background(InputVC(input: $input))
    }
}

extension View {
    public func simpleInput(_ input: Binding<SimpleInput?>) -> some View {
        self
            .modifier(SimpleInputModifier(input: input))
    }
}
