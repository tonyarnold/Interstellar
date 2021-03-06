// Result.swift
//
// Copyright (c) 2015 Jens Ravens (http://jensravens.de)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

/// This protocol works as a placeholder for Swift2's ErrorType protocol.
public protocol ErrorType {
    
}

/// NSError conforms to ErrorType. This is done automatically in Swift2.
extension NSError: ErrorType {
    
}

/**
    A result contains the result of a computation or task. It might be either successfull
    with an attached value or a failure with an attached error (which conforms to Swift 2's
    ErrorType). You can read more about the implementation in
    [this blog post](http://jensravens.de/a-swifter-way-of-handling-errors/).
    
    Due to a limitation in Swift 1.2 a Box type is needed to wrap the contents of a .Success.

        let result = Result.Success(Box("Hello"))

    This will no longer be needed in Swift 2.
*/
public enum Result<T> {
    case Success(Box<T>)
    case Error(ErrorType)
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func map<U>(f: T -> U) -> Result<U> {
        switch self {
        case let .Success(v): return .Success(Box(f(v.value)))
        case let .Error(error): return .Error(error)
        }
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func map<U>(f:(T, (U->Void))->Void) -> (Result<U>->Void)->Void {
        return { g in
            switch self {
            case let .Success(v): f(v.value){ transformed in
                    g(.Success(Box(transformed)))
                }
            case let .Error(error): g(.Error(error))
            }
        }
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func bind<U>(f: T -> Result<U>) -> Result<U> {
        switch self {
        case let .Success(v): return f(v.value)
        case let .Error(error): return .Error(error)
        }
    }
    
    /**
        Transform a result into another result using a function. If the result was an error,
        the function will not be executed and the error returned instead.
    */
    public func bind<U>(f:(T, (Result<U>->Void))->Void) -> (Result<U>->Void)->Void {
        return { g in
            switch self {
            case let .Success(v): f(v.value, g)
            case let .Error(error): g(.Error(error))
            }
        }
    }
    
    /** 
        Call a function with the result as an argument. Use this if the function should be
        executed no matter if the result was a success or not.
    */
    public func ensure<U>(f: Result<T> -> Result<U>) -> Result<U> {
        return f(self)
    }
    
    /**
        Call a function with the result as an argument. Use this if the function should be
        executed no matter if the result was a success or not.
    */
    public func ensure<U>(f:(Result<T>, (Result<U>->Void))->Void) -> (Result<U>->Void)->Void {
        return { g in
            f(self, g)
        }
    }
    
    /**
        Direct access to the content of the result as an optional. If the result was a success,
        the optional will contain the value of the result.
    */
    public var value: T? {
        switch self {
        case let .Success(v): return v.value
        case let .Error(error): return nil
        }
    }
}