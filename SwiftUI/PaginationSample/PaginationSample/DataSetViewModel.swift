import Foundation

@Observable
class DataSetViewModel {
    private let dataRepository: DataRepository
    private let batchSize: Int = 8
    @ObservationIgnored
    private var latestItemRead: Item?
    @MainActor private(set) var items: [Item] = []
    var triggerFetchTask: Bool = true

    @ObservationIgnored
    private var hasMoreItemsToFetch: Bool {
        let total = getTotalItemsCount()
        return items.count < total
    }

    init(dataRepository: DataRepository = DataRepository()) {
        self.dataRepository = dataRepository
    }

    private func getTotalItemsCount() -> Int {
        return dataRepository.getTotalItemsCount()
    }

    private func shouldFetchNextBatch(lastVisibleItem: Item) -> Bool {
        if lastVisibleItem == items.last && hasMoreItemsToFetch {
            return true
        }
        return false
    }

    func fetchNextBatch() async {
        let batch = await dataRepository.fetchNextBatch(from: latestItemRead, batchSize: batchSize)
        latestItemRead = batch.last
        items.append(contentsOf: batch)
    }
}
