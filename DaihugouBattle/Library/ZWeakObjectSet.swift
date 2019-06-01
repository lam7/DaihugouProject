//	ZWeekObjectSet.swift
//	ZKit
//
//	The MIT License (MIT)
//
//	Copyright (c) 2019 Electricwoods LLC, Kaz Yoshikawa.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy 
//	of this software and associated documentation files (the "Software"), to deal 
//	in the Software without restriction, including without limitation the rights 
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
//	copies of the Software, and to permit persons to whom the Software is 
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in 
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
//	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//	Swift 4.2

import Foundation


fileprivate class ZWeakObject<T: AnyObject>: Equatable, Hashable {

	weak var object: T?

	init(_ object: T) {
		self.object = object
	}
	
	public var hashValue: Int {
		if let object = self.object { return ObjectIdentifier(object).hashValue }
		else { return 0 }
	}

	public static func == <T> (lhs: ZWeakObject<T>, rhs: ZWeakObject<T>) -> Bool {
		return lhs.object === rhs.object
	}
}


public class ZWeakObjectSet<T: AnyObject>: Sequence {

	private var _objects: Set<ZWeakObject<T>>
	
	public var objects: [T] {
		return self._objects.compactMap { $0.object }
	}

	public init() {
		self._objects = Set<ZWeakObject<T>>([])
	}

	public init(_ objects: [T]) {
		self._objects = Set<ZWeakObject<T>>(objects.map { ZWeakObject($0) })
	}

	public func contains(_ object: T) -> Bool {
		return self._objects.contains(ZWeakObject(object))
	}

	public func add(_ object: T) {
		self._objects.formUnion([ZWeakObject(object)])
	}

	public func add(_ objects: [T]) {
		self._objects.formUnion(objects.map { ZWeakObject($0) })
	}
	
	public func remove(_ object: T) {
		self._objects.remove(ZWeakObject<T>(object))
	}

	public func remove(_ objects: [T]) {
		self._objects.subtract(objects.map { ZWeakObject($0) })
	}
    
    public func removeAll() {
        self._objects.removeAll()
    }

	public func makeIterator() -> ZWeakObjectSetIterator<T> {
		return ZWeakObjectSetIterator(self.objects)
	}

}


public struct ZWeakObjectSetIterator<T: AnyObject>: IteratorProtocol {

	private let objects: [T]
	private var index: Int = 0

	fileprivate init(_ objects: [T]) {
		self.objects = objects
	}

	mutating public func next() -> T? {
		if index < objects.count {
			defer { index += 1 }
			return objects[index]
		}
		return nil
	}

}


