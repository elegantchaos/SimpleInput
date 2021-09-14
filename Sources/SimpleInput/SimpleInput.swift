// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 14/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

extension UIAlertController {
    convenience init(input: SimpleInput, completion: @escaping () -> ()) {
        self.init(title: input.title, message: input.message, preferredStyle: .alert)
        addTextField { $0.placeholder = input.placeholder }

        if let action = input.cancel?.action(completion: completion) {
            addAction(action)
        }
        
        addAction(input.submit.action(field: self.textFields?.first, completion: completion))
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

public enum Button {
    case normal(String,(String) -> ())
    case destructive(String, (String) -> ())
    case cancel(String = "Cancel", () -> ())
    
    func action(field: UITextField? = nil, completion: @escaping () -> ()) -> UIAlertAction {
        switch self {
            case .normal(let title, let action):
                return UIAlertAction(title: title, style: .default) { _ in
                    action(field?.text ?? "")
                    completion()
                }
                
            case .destructive(let title, let action):
                return UIAlertAction(title: title, style: .destructive) { _ in
                    action(field?.text ?? "")
                    completion()
                }

            case .cancel(let title, let action):
                return UIAlertAction(title: title, style: .cancel) { _ in
                    action()
                    completion()
                }
        }

    }
}

public struct SimpleInput {
    public init(title: String, message: String, placeholder: String = "", submit: Button, cancel: Button? = nil) {
        self.title = title
        self.message = message
        self.placeholder = placeholder
        self.submit = submit
        self.cancel = cancel
    }
    
    public var title: String
    public var message: String
    public var placeholder: String
    public var submit: Button
    public var cancel: Button?
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
