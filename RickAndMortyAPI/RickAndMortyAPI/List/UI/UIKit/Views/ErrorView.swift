import UIKit

public final class ErrorView: UIView {
    private var label = UILabel()

    public var message: String? {
        get { return isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }

    public init() {
        super.init(frame: .zero)

        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        addSubview(label)

        label.text = nil
        alpha = 0
        backgroundColor = .systemRed

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideMessageAnimated))
        label.addGestureRecognizer(tapGesture)
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8)
        ])
    }

    private var isVisible: Bool {
        return alpha > 0
    }

    private func setMessageAnimated(_ message: String?) {
         if let message = message {
             showAnimated(message)
         } else {
             hideMessageAnimated()
         }
     }

    private func showAnimated(_ message: String) {
        label.text = message

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }

    @objc private func hideMessageAnimated() {
         UIView.animate(
             withDuration: 0.25,
             animations: { self.alpha = 0 },
             completion: { completed in
                 if completed { self.label.text = nil }
             })
     }
}
