import UIKit

public protocol CharacterCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class CharacterCellController: CharacterImageView {
    private let delegate: CharacterCellControllerDelegate
    private var cell: CharacterCell?

    public init(delegate: CharacterCellControllerDelegate) {
        self.delegate = delegate
    }

    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }

    func preload() {
        delegate.didRequestImage()
    }

    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }

    public func display(_ viewModel: CharacterViewModel<UIImage>) {
        cell?.nameLabel.text = viewModel.name
        cell?.speciesLabel.text = viewModel.species
        cell?.genderLabel.text = viewModel.gender
        cell?.characterImageView.setImageAnimated(viewModel.image)
        cell?.characterContainer.isShimmering = viewModel.isLoading
        cell?.characterRetryButton.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }

    private func releaseCellForReuse() {
        cell = nil
    }
}
