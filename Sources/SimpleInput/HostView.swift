// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 15/09/21.
//  All code (c) 2021 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI

internal struct HostView: UIViewControllerRepresentable{
    @Binding var input: SimpleInput?

    class EmptyViewController: UIViewController {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: Context) -> EmptyViewController {
        return EmptyViewController()
    }
    
    func updateUIViewController(_ controller: EmptyViewController, context: Context) {
        let coordinator = context.coordinator
        let alertShowing = controller.presentedViewController != nil
        
        if !alertShowing, let alert = makeAlertController(coordinator: coordinator) {
            controller.present(alert, animated: true)

        } else if alertShowing, input == nil {
            context.coordinator.alert?.dismiss(animated: true)
            coordinator.reset()
        }
    }
    
    fileprivate func makeAlertController(coordinator: Coordinator) -> UIAlertController? {
        guard let input = input else { return nil }
        
        let controller = UIAlertController(title: input.title, message: input.message, preferredStyle: .alert)
        controller.addTextField {
            let settings = input.field
            $0.placeholder = settings.placeholder
            $0.text = settings.value
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
            let action = button.action(field: controller.textFields?.first) {
                coordinator.reset()
                self.input = nil
            }
            
            controller.addAction(action)
        }

        coordinator.setup(alert: controller, input: input)
        return controller
    }
}

