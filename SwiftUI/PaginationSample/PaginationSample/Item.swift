import Foundation

struct Item: Identifiable, Equatable {
    let id: String = UUID().uuidString
    let createdDate: Date
    let title: String
    let subtitle: String
    let imageName: String

    static let systemImages = ["star", "heart", "bolt", "cloud", "sun.max", "moon", "flame", "leaf", "bell", "gift",
                                   "cart", "house", "car", "airplane", "bicycle", "tram", "bus", "drop.halffull", "bed.double", "gauge",
                                   "gamecontroller", "tv", "headphones", "lightbulb", "clock", "camera", "phone", "laptopcomputer", "paintbrush", "wand.and.stars"]

    static let titles = ["Featured", "Popular", "Recommended", "Trending", "New Arrival", "Editor's Pick", "Best Seller", "Limited Edition", "Classic", "Modern"]

    static let subtitles = [
        "A must-have item because it is top-rated by users and consistently gets excellent reviews across the board.",
        "Top-rated by users for its quality and performance, making it a standout choice in the market.",
        "Highly recommended by industry experts and users alike for its exceptional value and reliability.",
        "Customers love this item because of its high performance and reliability, plus it's been recently updated to meet modern needs.",
        "Recently updated with new features, this item has quickly gained popularity among users for its innovation and utility.",
        "Exclusive release, limited edition, and available only for a short time, don’t miss your chance to own it!",
        "Stylish and functional, this item is perfect for any occasion, blending form and function seamlessly for everyday use.",
        "Perfect for any occasion, whether you're dressing up for a special event or adding elegance to your daily routine.",
        "Best value for your money, combining quality, durability, and price in one highly affordable package.",
        "Premium quality, very popular, and highly featured in the latest trends, a must-have for enthusiasts and collectors alike."
    ]

    static var mockedItems: [Item] {
        let items = (0..<150).map { index in
            Item(
                createdDate: Date(),
                title: titles[index % titles.count],
                subtitle: subtitles[index % subtitles.count],
                imageName: systemImages[index % systemImages.count]
            )
        }
        return items.sorted { $0.createdDate > $1.createdDate }
    }
}
