//
//  MockURLSession.swift
//  MoveFastPhoto
//
//  Created by Diego Karlo Manansala on 12/04/2020.
//  Copyright © 2020 Diego Karlo Manansala. All rights reserved.
//

import Foundation

public protocol MyURLSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: MyURLSession { }

class MockURLSession: MyURLSession {
    var cachedUrl: URL?
    private let dataTaskMock: URLSessionDataTaskMock
    
    public init(data: Data? = nil) {
        dataTaskMock = URLSessionDataTaskMock(data: data)
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.cachedUrl = url
        return self.dataTaskMock
    }
    
    func dataTask(with: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTaskMock
    }
    
    final private class URLSessionDataTaskMock: URLSessionDataTask {
        public init(data: Data? = nil) {
            
        }
    }
}
