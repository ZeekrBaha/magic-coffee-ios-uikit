import CoreData

final class DataSeeder {
    static func seedIfNeeded() async {
        guard !UserDefaults.standard.bool(forKey: "mc_seeded") else { return }
        do {
            try await CoreDataStack.shared.performBackgroundTask { context in
                Self.seedProducts(in: context)
                Self.seedStores(in: context)
                Self.seedBaristas(in: context)
                try context.save()
            }
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: "mc_seeded")
            }
        } catch {
            // Seeding is best-effort: the `mc_seeded` flag stays unset, so it retries next launch.
        }
    }

    static func seedProducts(in context: NSManagedObjectContext) {
        // Idempotent: never duplicate if products already exist.
        guard ((try? context.count(for: CDProduct.fetchRequest())) ?? 0) == 0 else { return }
        let items: [(name: String, path: String, price: Double, sort: Int16)] = [
            ("Americano",  "products/americano",  3.0, 0),
            ("Cappuccino", "products/cappuccino", 3.0, 1),
            ("Latte",      "products/latte",      3.0, 2),
            ("Flat White", "products/flat_white", 3.0, 3),
            ("Raf",        "products/raf",        3.0, 4),
            ("Espresso",   "products/espresso",   3.0, 5),
        ]
        for item in items {
            let p = CDProduct(context: context)
            p.id = UUID()
            p.name = item.name
            p.imagePath = item.path
            p.price = NSDecimalNumber(value: item.price)
            p.sortOrder = item.sort
        }
    }

    static func seedStores(in context: NSManagedObjectContext) {
        // Idempotent: never duplicate if stores already exist.
        guard ((try? context.count(for: CDStore.fetchRequest())) ?? 0) == 0 else { return }
        let stores: [(name: String, address: String, lat: Double, lon: Double)] = [
            ("Bradford 804 914", "Bradford BD1 914", 53.7946, -1.7560),
            ("Bradford 804 7SJ", "Bradford BD4 7SJ", 53.7956, -1.7570),
            ("Bradford 804 406", "Bradford BD4 406", 53.7936, -1.7550),
        ]
        for s in stores {
            let store = CDStore(context: context)
            store.id = UUID()
            store.name = s.name
            store.address = s.address
            store.latitude = s.lat
            store.longitude = s.lon
        }
    }

    static func seedBaristas(in context: NSManagedObjectContext) {
        // Idempotent: never duplicate if baristas already exist.
        guard ((try? context.count(for: CDBarista.fetchRequest())) ?? 0) == 0 else { return }
        let baristas: [(name: String, specialty: String, available: Bool)] = [
            ("Victor", "Top Aristica", true),
            ("Andrey", "Espresso",     true),
            ("Sofia",  "Latte Art",    false),
        ]
        for b in baristas {
            let barista = CDBarista(context: context)
            barista.id = UUID()
            barista.name = b.name
            barista.specialty = b.specialty
            barista.isAvailable = b.available
        }
    }
}
