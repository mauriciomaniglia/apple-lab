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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupView() {
        contentView.addSubview(stackView)
        characterContainer.addSubview(characterRetryButton)
        characterContainer.addSubview(characterImageView)
        stackView.addArrangedSubview(characterContainer)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(speciesLabel)
        stackView.addArrangedSubview(genderLabel)

        selectionStyle = .none

        let buttonTapGesture = UITapGestureRecognizer(target: self, action: #selector(retryButtonTapped))
        characterRetryButton.addGestureRecognizer(buttonTapGesture)
    }

    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        characterContainer.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            characterImageView.heightAnchor.constraint(equalToConstant: 300),
            characterImageView.leadingAnchor.constraint(equalTo: characterContainer.leadingAnchor),
            characterImageView.trailingAnchor.constraint(equalTo: characterContainer.trailingAnchor),
            characterImageView.topAnchor.constraint(equalTo: characterContainer.topAnchor),
            characterImageView.bottomAnchor.constraint(equalTo: characterContainer.bottomAnchor),

            characterRetryButton.heightAnchor.constraint(equalToConstant: 300),
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
