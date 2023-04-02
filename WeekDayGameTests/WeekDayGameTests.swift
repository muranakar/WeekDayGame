//
//  WeekDayGameTests.swift
//  WeekDayGameTests
//
//  Created by 村中令 on 2022/10/12.
//

import XCTest
@testable import WeekDayGame

final class WeekDayGameTests: XCTestCase {

    var game  =  ZodiacGame(testQuiz: ZodiacQuiz(first: 1, second: 1, third: 1, level: .easy), level: .easy)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        XCTAssertEqual(game.answer(), .rabbit)

    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
