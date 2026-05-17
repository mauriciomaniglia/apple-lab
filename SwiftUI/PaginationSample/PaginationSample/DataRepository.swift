import Foundation

class DataRepository {
    private var items: [Item] = []

    init() {
        items = Item.mockedItems
    }

    func fetchNextBatch(from latestItemRead: Item?, batchSize: Int) async -> [Item] {
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        guard let latestItem = latestItemRead, let index = items.firstIndex(where: { $0.id == latestItem.id }) else {
            return Array(items.prefix(batchSize))
        }

        let nextIndex = index + 1
        let endIndex = min(nextIndex + batchSize, items.count)

        guard nextIndex < items.count else {
            return []
        }

        let batch = Array(items[nextIndex..<endIndex])

        return batch
    }

    func getTotalItemsCount() -> Int {
        return items.count
    }
}
