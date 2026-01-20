import XCTest
@testable import MYPlanner

final class KeychainServiceTests: XCTestCase {
    
    var sut: KeychainService!
    
    override func setUp() {
        super.setUp()
        sut = KeychainService(service: "com.myplanner.test")
    }
    
    override func tearDown() {
        sut.delete(forKey: "test_key")
        sut.deleteAPIKey()
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Set Tests

    func testSet_withValidKeyAndValue_returnTrue() {
        // Arrange
        let key = "test_key"
        let value = "test_value"

        // Act
        let result = sut.set(value, forKey: key)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - GetString Tests

    func test_getString_afterSet_returnsCorrectValue() {
        // Arrange
        let key = "test_key"
        let value = "secret_value"
        sut.set(value, forKey: key)

        // Act
        let retrieved = sut.getString(forKey: key)

        // Assert
        XCTAssertEqual(retrieved, value)
    }

    func test_getString_withNonExistentKey_returnsNil() {
        // Arrange
        let nonExistentKey = "non_existent"

        // Act
        let result = sut.getString(forKey: nonExistentKey)

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - Get Tests (Type Conversion)

    func test_get_withBoolTrue_returnsBool() {
        // Arrange
        sut.set(true, forKey: "test_key")

        // Act
        let result = sut.get(forKey: "test_key") as? Bool

        // Assert
        XCTAssertEqual(result, true)
    }

    func test_get_withBoolFalse_returnsBool() {
        // Arrange
        sut.set(false, forKey: "test_key")

        // Act
        let result = sut.get(forKey: "test_key") as? Bool

        // Assert
        XCTAssertEqual(result, false)
    }

    func test_get_withInteger_returnsInt() {
        // Arrange
        sut.set(42, forKey: "test_key")

        // Act
        let result = sut.get(forKey: "test_key") as? Int

        // Assert
        XCTAssertEqual(result, 42)
    }

    func test_get_withString_returnsString() {
        // Arrange
        sut.set("hello", forKey: "test_key")

        // Act
        let result = sut.get(forKey: "test_key") as? String

        // Assert
        XCTAssertEqual(result, "hello")
    }

    // MARK: - Delete Tests

    func test_delete_existingKey_returnsTrue() {
        // Arrange
        sut.set("value_to_delete", forKey: "test_key")

        // Act
        let result = sut.delete(forKey: "test_key")

        // Assert
        XCTAssertTrue(result)
    }

    func test_delete_existingKey_removesData() {
        // Arrange
        sut.set("value_to_delete", forKey: "test_key")

        // Act
        sut.delete(forKey: "test_key")
        let retrieved = sut.get(forKey: "test_key")

        // Assert
        XCTAssertNil(retrieved)
    }

    func test_delete_nonExistentKey_returnsTrue() {
        // Arrange
        let nonExistentKey = "never_saved_key"

        // Act
        let result = sut.delete(forKey: nonExistentKey)

        // Assert
        XCTAssertTrue(result)
    }

    // MARK: - API Key Convenience Methods Tests

    func test_saveAPIKey_withValidKey_returnsTrue() {
        // Arrange
        let apiKey = "sk-ant-api03-test-key"

        // Act
        let result = sut.saveAPIKey(apiKey)

        // Assert
        XCTAssertTrue(result)
    }

    func test_retrieveAPIKey_afterSave_returnsKey() {
        // Arrange
        let apiKey = "sk-ant-api03-test-key"
        sut.saveAPIKey(apiKey)

        // Act
        let retrieved = sut.retrieveAPIKey()

        // Assert
        XCTAssertEqual(retrieved, apiKey)
    }

    func test_retrieveAPIKey_withNoKey_returnsNil() {
        // Arrange - ensure no key exists
        sut.deleteAPIKey()

        // Act
        let result = sut.retrieveAPIKey()

        // Assert
        XCTAssertNil(result)
    }

    func test_hasAPIKey_afterSave_returnsTrue() {
        // Arrange
        sut.saveAPIKey("sk-ant-api03-test-key")

        // Act
        let result = sut.hasAPIKey

        // Assert
        XCTAssertTrue(result)
    }

    func test_hasAPIKey_withNoKey_returnsFalse() {
        // Arrange
        sut.deleteAPIKey()

        // Act
        let result = sut.hasAPIKey

        // Assert
        XCTAssertFalse(result)
    }

    func test_deleteAPIKey_afterSave_removesKey() {
        // Arrange
        sut.saveAPIKey("sk-ant-api03-test-key")

        // Act
        sut.deleteAPIKey()
        let retrieved = sut.retrieveAPIKey()

        // Assert
        XCTAssertNil(retrieved)
    }
}
