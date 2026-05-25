import Combine
import Foundation

/// Drives the post-order review modal (screen 26).
///
/// There is no backend or `CDReview` entity, so the rating lives only in memory for
/// the lifetime of the modal. The view model's job is to hold the selected star
/// rating and expose whether a rating has been chosen.
final class ReviewViewModel: BaseViewModel {

    /// Selected rating, 0 means "no rating chosen yet". Valid range when set is 1...5.
    @Published private(set) var rating: Int = 0

    /// A rating can be submitted once at least one star is selected.
    var canSubmit: Bool { rating >= 1 }

    /// Sets the rating, ignoring values outside the 1...5 star range.
    func selectRating(_ value: Int) {
        guard (1...5).contains(value) else { return }
        rating = value
    }
}
