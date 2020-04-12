//
//  MoveFastPhotoTests.swift
//  MoveFastPhotoTests
//
//  Created by Diego Karlo Manansala on 07/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import XCTest
@testable import MoveFastPhoto

class MoveFastPhotoTests: XCTestCase {
    var networkApi: Network!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        self.networkApi = Network()
        self.mockURLSession = MockURLSession(data: nil)
        self.networkApi.session = mockURLSession
    }

    override func tearDown() {
        self.networkApi.session = nil
        self.mockURLSession = nil
        self.networkApi = nil
    }
    
    func testGetPhotosSuccessCompletes() {
        let promise = expectation(description: "Movies Successful")
        var imagesResponse: [Photo]?
        var successResponse: Bool?
        self.networkApi.getPhotos { (images, success) in
            imagesResponse = images
            successResponse = success
            promise.fulfill()
        }
        
        waitForExpectations(timeout: 8) { (error) in
            XCTAssertTrue(successResponse ?? false)
            XCTAssertNotNil(imagesResponse)
        }
    }
    
    func testGetPhotosSuccessReturns10Images() {
        let promise = expectation(description: "Movies")
        var imagesResponse: [Photo]?
        var successResponse: Bool?
        self.networkApi.getPhotos(page: 1, limit: 10, completionHandler: { (images, success) in
            imagesResponse = images
            successResponse = success
            promise.fulfill()
        })
        
        waitForExpectations(timeout: 8) { (error) in
            XCTAssertTrue(successResponse ?? false)
            XCTAssertEqual(imagesResponse!.count, 10)
        }
    }

}
