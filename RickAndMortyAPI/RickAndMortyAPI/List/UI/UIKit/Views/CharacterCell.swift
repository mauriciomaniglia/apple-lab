import UIKit

public final class CharacterCell: UITableViewCell {
    static let reuseIdentifier = "\(CharacterCell.self)"

    private(set) public var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView
    }()

    private(set) public var nameLabel: UILabel = UILabel()
    private(set) public var speciesLabel = UILabel()
    private(set) public var genderLabel = UILabel()
    private(set) public var characterContainer = UIView()
    private(set) public var characterImageView = UIImageView()
    private(set) public var characterRetryButton: UIButton = {
        let button = UIButton()
        button.setTitle("↻", for: .normal)
        return button
    }()

    var onRetry: (() -> Void)?

    public init() {
        super.init(style: .default, reuseIdentifier: CharacterCell.reuseIdentifier)

        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(characterContainer)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(speciesLabel)
        stackView.addArrangedSubview(genderLabel)

        let buttonTapGesture = UITapGestureRecognizer(target: self, action: #selector(retryButtonTapped))
        characterRetryButton.addGestureRecognizer(buttonTapGesture)
    }

    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        characterContainer.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 8),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 8),

            characterImageView.leadingAnchor.constraint(equalTo: characterContainer.leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: characterContainer.trailingAnchor),
            characterImageView.topAnchor.constraint(equalTo: characterContainer.topAnchor),
            characterImageView.bottomAnchor.constraint(equalTo: characterContainer.bottomAnchor),

            characterRetryButton.leadingAnchor.constraint(equalTo: characterContainer.leadingAnchor),
            characterRetryButton.trailingAnchor.constraint(equalTo: characterContainer.trailingAnchor),
            characterRetryButton.topAnchor.constraint(equalTo: characterContainer.topAnchor),
            characterRetryButton.bottomAnchor.constraint(equalTo: characterContainer.bottomAnchor),
        ])
    }

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
