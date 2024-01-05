import XCTest
import Decide

final class Decide_Tests: XCTestCase {
    @EnvironmentObservable
    final class Notes {
        @Persistent
        var name: String = ""
        
        var count: Int = 0
    }
}
