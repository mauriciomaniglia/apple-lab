import UIKit

public protocol CharactersViewControllerDelegate {
   func didRequestCharactersRefresh()
}

public final class CharactersViewController: UITableViewController, UITableViewDataSourcePrefetching, CharactersLoadingView, CharactersErrorView {
    private(set) public var errorView: ErrorView?

    public var delegate: CharactersViewControllerDelegate?

    private var tableModel = [CharacterCellController]() {
        didSet { tableView.reloadData() }
    }

    private var loadingControllers = [IndexPath: CharacterCellController]()
    private var onViewIsAppearing: ((CharactersViewController) -> Void)?

    public override func viewDidLoad() {
        super.viewDidLoad()

        onViewIsAppearing = { vc in
            vc.onViewIsAppearing = nil
            vc.refresh()
        }

        tableView.register(CharacterCell.self, forCellReuseIdentifier: CharacterCell.reuseIdentifier)
        tableView.separatorStyle = .none
    }

    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        onViewIsAppearing?(self)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        tableView.sizeTableHeaderToFit()
    }

    public func display(_ cellControllers: [CharacterCellController]) {
        loadingControllers = [:]
        tableModel = cellControllers
     }

    private func refresh() {
         delegate?.didRequestCharactersRefresh()
     }

    public func display(_ viewModel: CharactersLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
     }

    public func display(_ viewModel: CharactersErrorViewModel) {
         errorView?.message = viewModel.message
     }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(in: tableView)
    }

    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }

    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> CharacterCellController {
        let controller = tableModel[indexPath.row]
        loadingControllers[indexPath] = controller
        return controller
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelLoad()
        loadingControllers[indexPath] = nil
    }
}

