import UIKit
import RickAndMortyAPI

extension CharactersViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }

        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }

    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithFakeForiOS17PlusSupport()
    }

    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }

    private func replaceRefreshControlWithFakeForiOS17PlusSupport() {
        let fakeRefreshControl = FakeUIRefreshControl()

        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fakeRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }

        refreshControl = fakeRefreshControl
    }

    private class FakeUIRefreshControl: UIRefreshControl {
        private var _isRefreshing = false

        override var isRefreshing: Bool { _isRefreshing }

        override func beginRefreshing() {
            _isRefreshing = true
        }

        override func endRefreshing() {
            _isRefreshing = false
        }
    }

    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }

    var isShowingLoadingIndicator: Bool {
        return refreshControl?.isRefreshing == true
    }

    func numberOfRenderedCharacterViews() -> Int {
        numberOfRows(in: 0)
    }

    func characterView(at row: Int) -> UITableViewCell? {
        cell(row: row, section: 0)
    }

    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }

    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }

    var errorMessage: String? {
        return errorView.message
    }

    func simulateErrorViewTap() {
        errorView.simulateTap()
    }

    var isShowingLoadMoreCharactersIndicator: Bool {
        let loadMoreView = tableView.tableFooterView as? LoadMoreCell
        return loadMoreView?.isLoading == true
    }

    var loadMoreCharactersErrorMessage: String? {
        let loadMoreView = tableView.tableFooterView as? LoadMoreCell
        return loadMoreView?.message
    }

    @discardableResult
    func simulateCharacterViewVisible(at row: Int) -> CharacterCell? {
        return cell(row: row, section: 0) as? CharacterCell
    }

    @discardableResult
    func simulateCharacterViewNotVisible(at row: Int) -> CharacterCell? {
        let view = simulateCharacterViewVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: 0)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: index)

        return view
    }

    @discardableResult
    func simulateCharacterViewBecomingVisibleAgain(at row: Int) -> CharacterCell? {
        let view = simulateCharacterViewNotVisible(at: row)

        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: 0)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)

        return view
    }
}
