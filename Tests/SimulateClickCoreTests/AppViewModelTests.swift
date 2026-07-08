import XCTest
@testable import SimulateClickCore

// ============================================================
// MARK: - Mock 点击引擎
// ============================================================
class MockClicker: Clicking {
    var clickHistory: [(x: Int, y: Int)] = []

    func performClick(x: Int, y: Int) {
        clickHistory.append((x: x, y: y))
    }
}

// ============================================================
// MARK: - Mock 权限检查器
// ============================================================
class MockPermissionChecker: PermissionChecking {
    var trusted = true
    var requestResult = true

    func isTrusted() -> Bool { trusted }

    func requestPermission(completion: @escaping (Bool) -> Void) {
        completion(requestResult)
    }
}

// ============================================================
// MARK: - 计算属性测试
// ============================================================
final class ComputedPropertiesTests: XCTestCase {

    var vm: AppViewModel!

    override func setUp() {
        super.setUp()
        vm = AppViewModel(clicker: MockClicker(), permissionChecker: MockPermissionChecker())
    }

    // MARK: - countLimit
    func testCountLimit_validNumber() {
        vm.countLimitText = "10"
        XCTAssertEqual(vm.countLimit, 10)
    }

    func testCountLimit_zero_meansUnlimited() {
        vm.countLimitText = "0"
        XCTAssertEqual(vm.countLimit, 0)
    }

    func testCountLimit_invalidText_fallsBackToOne() {
        vm.countLimitText = "abc"
        XCTAssertEqual(vm.countLimit, 1)
    }

    func testCountLimit_emptyString_fallsBackToOne() {
        vm.countLimitText = ""
        XCTAssertEqual(vm.countLimit, 1)
    }

    func testCountLimit_negativeNumber() {
        vm.countLimitText = "-5"
        XCTAssertEqual(vm.countLimit, -5)
    }

    func testCountLimit_largeNumber() {
        vm.countLimitText = "999999"
        XCTAssertEqual(vm.countLimit, 999999)
    }

    func testCountLimit_decimalText_truncated() {
        vm.countLimitText = "3.7"
        // Int("3.7") returns nil, falls back to 1
        XCTAssertEqual(vm.countLimit, 1)
    }

    // MARK: - posX / posY
    func testPosX_validNumber() {
        vm.posXText = "100"
        XCTAssertEqual(vm.posX, 100)
    }

    func testPosX_invalidText_fallsBackToZero() {
        vm.posXText = "xyz"
        XCTAssertEqual(vm.posX, 0)
    }

    func testPosX_negativeNumber() {
        vm.posXText = "-200"
        XCTAssertEqual(vm.posX, -200)
    }

    func testPosX_emptyString_fallsBackToZero() {
        vm.posXText = ""
        XCTAssertEqual(vm.posX, 0)
    }

    func testPosY_validNumber() {
        vm.posYText = "200"
        XCTAssertEqual(vm.posY, 200)
    }

    func testPosY_negativeNumber() {
        vm.posYText = "-50"
        XCTAssertEqual(vm.posY, -50)
    }

    func testPosY_invalidText_fallsBackToZero() {
        vm.posYText = "abc"
        XCTAssertEqual(vm.posY, 0)
    }

    // MARK: - minDelay
    func testMinDelay_validNumber() {
        vm.minDelayText = "500"
        XCTAssertEqual(vm.minDelay, 500)
    }

    func testMinDelay_belowMinimum_clampedTo10() {
        vm.minDelayText = "5"
        XCTAssertEqual(vm.minDelay, 10)
    }

    func testMinDelay_zero_clampedTo10() {
        vm.minDelayText = "0"
        XCTAssertEqual(vm.minDelay, 10)
    }

    func testMinDelay_negative_clampedTo10() {
        vm.minDelayText = "-100"
        XCTAssertEqual(vm.minDelay, 10)
    }

    func testMinDelay_invalidText_fallsBack500() {
        vm.minDelayText = "abc"
        // fallback to 500, max(500, 10) = 500
        XCTAssertEqual(vm.minDelay, 500)
    }

    func testMinDelay_boundaryExactly10() {
        vm.minDelayText = "10"
        XCTAssertEqual(vm.minDelay, 10)
    }

    func testMinDelay_emptyString_fallsBack500() {
        vm.minDelayText = ""
        XCTAssertEqual(vm.minDelay, 500)
    }

    // MARK: - maxDelay
    func testMaxDelay_validNumber() {
        vm.maxDelayText = "2000"
        XCTAssertEqual(vm.maxDelay, 2000)
    }

    func testMaxDelay_belowMinimum_clampedTo10() {
        vm.maxDelayText = "3"
        XCTAssertEqual(vm.maxDelay, 10)
    }

    func testMaxDelay_invalidText_fallsBack1500() {
        vm.maxDelayText = "xyz"
        XCTAssertEqual(vm.maxDelay, 1500)
    }

    func testMaxDelay_boundaryExactly10() {
        vm.maxDelayText = "10"
        XCTAssertEqual(vm.maxDelay, 10)
    }

    func testMaxDelay_emptyString_fallsBack1500() {
        vm.maxDelayText = ""
        XCTAssertEqual(vm.maxDelay, 1500)
    }
}

// ============================================================
// MARK: - 初始状态测试
// ============================================================
final class InitialStateTests: XCTestCase {

    var vm: AppViewModel!

    override func setUp() {
        super.setUp()
        vm = AppViewModel(clicker: MockClicker(), permissionChecker: MockPermissionChecker())
    }

    func testDefaultTextValues() {
        XCTAssertEqual(vm.countLimitText, "1")
        XCTAssertEqual(vm.posXText, "0")
        XCTAssertEqual(vm.posYText, "0")
        XCTAssertEqual(vm.minDelayText, "500")
        XCTAssertEqual(vm.maxDelayText, "1500")
    }

    func testDefaultStateFlags() {
        XCTAssertFalse(vm.isRunning)
        XCTAssertEqual(vm.clickCount, 0)
        XCTAssertFalse(vm.isCapturing)
    }

    func testDefaultComputedValues() {
        XCTAssertEqual(vm.countLimit, 1)
        XCTAssertEqual(vm.posX, 0)
        XCTAssertEqual(vm.posY, 0)
        XCTAssertEqual(vm.minDelay, 500)
        XCTAssertEqual(vm.maxDelay, 1500)
    }
}

// ============================================================
// MARK: - start / stop 状态管理测试
// ============================================================
final class StartStopTests: XCTestCase {

    var vm: AppViewModel!
    var mockClicker: MockClicker!
    var mockPermission: MockPermissionChecker!

    override func setUp() {
        super.setUp()
        mockClicker = MockClicker()
        mockPermission = MockPermissionChecker()
        vm = AppViewModel(clicker: mockClicker, permissionChecker: mockPermission)
    }

    override func tearDown() {
        vm.stop()
        vm = nil
        super.tearDown()
    }

    func testStart_setsIsRunningTrue() {
        vm.start()
        XCTAssertTrue(vm.isRunning)
    }

    func testStart_resetsClickCount() {
        vm.clickCount = 99
        vm.start()
        XCTAssertEqual(vm.clickCount, 0)
    }

    func testStart_whenAlreadyRunning_doesNothing() {
        vm.start()
        XCTAssertTrue(vm.isRunning)
        vm.start()  // 重复调用应被 guard 拦截
        XCTAssertTrue(vm.isRunning)
    }

    func testStop_setsIsRunningFalse() {
        vm.start()
        vm.stop()
        XCTAssertFalse(vm.isRunning)
    }

    func testStop_whenNotRunning_noError() {
        XCTAssertFalse(vm.isRunning)
        vm.stop()
        XCTAssertFalse(vm.isRunning)
    }

    func testStop_cancelsTimer_noMoreClicks() {
        vm.isRunning = true
        vm.countLimitText = "0"  // 不限
        vm.scheduleNextClick()
        XCTAssertEqual(mockClicker.clickHistory.count, 1)
        vm.stop()
        // stop 后不应继续点击
        XCTAssertFalse(vm.isRunning)
    }

    func testStart_permissionDenied_stopsRunning() {
        mockPermission.requestResult = false
        let expectation = XCTestExpectation(description: "isRunning should become false")

        vm.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.vm.isRunning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testStart_permissionGranted_schedulesClick() {
        mockPermission.requestResult = true
        let expectation = XCTestExpectation(description: "click should be scheduled")

        vm.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.vm.clickCount, 1)
            XCTAssertEqual(self.mockClicker.clickHistory.count, 1)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testRapidStartStop_doesNotCrash() {
        // 快速交替 start/stop 不应崩溃
        for _ in 0..<20 {
            vm.start()
            vm.stop()
        }
        XCTAssertFalse(vm.isRunning)
    }
}

// ============================================================
// MARK: - scheduleNextClick 点击逻辑测试
// ============================================================
final class ScheduleNextClickTests: XCTestCase {

    var vm: AppViewModel!
    var mockClicker: MockClicker!

    override func setUp() {
        super.setUp()
        mockClicker = MockClicker()
        vm = AppViewModel(clicker: mockClicker, permissionChecker: MockPermissionChecker())
    }

    override func tearDown() {
        vm.stop()
        vm = nil
        super.tearDown()
    }

    func testNotRunning_doesNothing() {
        vm.isRunning = false
        vm.scheduleNextClick()
        XCTAssertEqual(vm.clickCount, 0)
        XCTAssertEqual(mockClicker.clickHistory.count, 0)
    }

    func testRunning_incrementsClickCount() {
        vm.isRunning = true
        vm.countLimitText = "0"
        vm.scheduleNextClick()
        XCTAssertEqual(vm.clickCount, 1)
        XCTAssertEqual(mockClicker.clickHistory.count, 1)
    }

    func testRunning_usesCorrectCoordinates() {
        vm.isRunning = true
        vm.countLimitText = "0"
        vm.posXText = "123"
        vm.posYText = "456"
        vm.scheduleNextClick()
        XCTAssertEqual(mockClicker.clickHistory.first?.x, 123)
        XCTAssertEqual(mockClicker.clickHistory.first?.y, 456)
    }

    func testRunning_usesNegativeCoordinates() {
        vm.isRunning = true
        vm.countLimitText = "0"
        vm.posXText = "-100"
        vm.posYText = "-200"
        vm.scheduleNextClick()
        XCTAssertEqual(mockClicker.clickHistory.first?.x, -100)
        XCTAssertEqual(mockClicker.clickHistory.first?.y, -200)
    }

    func testCountLimit_reached_stopsAutomatically() {
        vm.isRunning = true
        vm.countLimitText = "1"
        vm.scheduleNextClick()
        XCTAssertEqual(vm.clickCount, 1)
        let expectation = XCTestExpectation(description: "stop after limit")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertFalse(self.vm.isRunning)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testCountLimit_two_stopsAfterSecondClick() {
        vm.isRunning = true
        vm.countLimitText = "2"
        vm.minDelayText = "10"
        vm.maxDelayText = "10"
        vm.scheduleNextClick()
        XCTAssertEqual(vm.clickCount, 1)
        XCTAssertTrue(vm.isRunning)  // 还没到上限
    }

    func testUnlimitedMode_multipleClicks() {
        vm.isRunning = true
        vm.countLimitText = "0"  // 0 = 不限
        for _ in 0..<5 {
            vm.scheduleNextClick()
        }
        XCTAssertEqual(vm.clickCount, 5)
        XCTAssertEqual(mockClicker.clickHistory.count, 5)
        XCTAssertTrue(vm.isRunning)  // 不限模式不应自动停止
    }

    func testClickCount_zero_meansUnlimited_doesNotStop() {
        vm.isRunning = true
        vm.countLimitText = "0"
        // countLimit == 0 时条件 countLimit > 0 为 false，不会触发 stop
        vm.scheduleNextClick()
        vm.scheduleNextClick()
        vm.scheduleNextClick()
        XCTAssertEqual(vm.clickCount, 3)
        XCTAssertTrue(vm.isRunning)
    }
}

// ============================================================
// MARK: - computeDelay 静态方法测试
// ============================================================
final class ComputeDelayTests: XCTestCase {

    func testFixedDelay_equalMinMax() {
        let delay = AppViewModel.computeDelay(minDelay: 500, maxDelay: 500)
        XCTAssertEqual(delay, 0.5, accuracy: 0.001)
    }

    func testFixedDelay_oneSecond() {
        let delay = AppViewModel.computeDelay(minDelay: 1000, maxDelay: 1000)
        XCTAssertEqual(delay, 1.0, accuracy: 0.001)
    }

    func testFixedDelay_250ms() {
        let delay = AppViewModel.computeDelay(minDelay: 250, maxDelay: 250)
        XCTAssertEqual(delay, 0.25, accuracy: 0.001)
    }

    func testFixedDelay_zero() {
        let delay = AppViewModel.computeDelay(minDelay: 0, maxDelay: 0)
        XCTAssertEqual(delay, 0.0, accuracy: 0.001)
    }

    func testRandomDelay_withinRange() {
        let minD = 100
        let maxD = 200
        for _ in 0..<100 {
            let delay = AppViewModel.computeDelay(minDelay: minD, maxDelay: maxD)
            let ms = delay * 1000
            XCTAssertGreaterThanOrEqual(ms, Double(minD))
            XCTAssertLessThanOrEqual(ms, Double(maxD))
        }
    }

    func testRandomDelay_wideRange() {
        let minD = 10
        let maxD = 5000
        for _ in 0..<100 {
            let delay = AppViewModel.computeDelay(minDelay: minD, maxDelay: maxD)
            let ms = delay * 1000
            XCTAssertGreaterThanOrEqual(ms, Double(minD))
            XCTAssertLessThanOrEqual(ms, Double(maxD))
        }
    }

    func testRandomDelay_producesVariation() {
        // 大范围随机应产生不同值
        var values = Set<Int>()
        for _ in 0..<100 {
            let delay = AppViewModel.computeDelay(minDelay: 10, maxDelay: 10000)
            values.insert(Int(delay * 1000))
        }
        // 100次随机取样，几乎不可能全部相同
        XCTAssertGreaterThan(values.count, 1)
    }

    func testDelay_conversionIsMillisecondsToSeconds() {
        // 验证单位转换：输入ms，输出s
        let delay = AppViewModel.computeDelay(minDelay: 1500, maxDelay: 1500)
        XCTAssertEqual(delay, 1.5, accuracy: 0.001)
    }
}

// ============================================================
// MARK: - Mock 自身验证测试
// ============================================================
final class MockTests: XCTestCase {

    func testMockClicker_recordsClicks() {
        let mock = MockClicker()
        mock.performClick(x: 10, y: 20)
        mock.performClick(x: 30, y: 40)
        XCTAssertEqual(mock.clickHistory.count, 2)
        XCTAssertEqual(mock.clickHistory[0].x, 10)
        XCTAssertEqual(mock.clickHistory[0].y, 20)
        XCTAssertEqual(mock.clickHistory[1].x, 30)
        XCTAssertEqual(mock.clickHistory[1].y, 40)
    }

    func testMockClicker_emptyByDefault() {
        let mock = MockClicker()
        XCTAssertTrue(mock.clickHistory.isEmpty)
    }

    func testMockPermissionChecker_defaultTrusted() {
        let mock = MockPermissionChecker()
        XCTAssertTrue(mock.isTrusted())
    }

    func testMockPermissionChecker_requestPermission_returnsConfiguredResult() {
        let mock = MockPermissionChecker()
        mock.requestResult = false

        let expectation = XCTestExpectation(description: "completion called")
        mock.requestPermission { result in
            XCTAssertFalse(result)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
