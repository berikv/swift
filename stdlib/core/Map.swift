//===--- Map.swift - Lazily map the elements of a Sequence ---------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

@public struct MapSequenceGenerator<Base: Generator, T>: Generator, Sequence {
  @public mutating func next() -> T? {
    let x = _base.next()
    if x {
      return _transform(x!)
    }
    return nil
  }
  
  @public func generate() -> MapSequenceGenerator {
    return self
  }
  
  var _base: Base
  var _transform: (Base.Element)->T
}

@public struct MapSequenceView<Base: Sequence, T> : Sequence {
  @public func generate() -> MapSequenceGenerator<Base.GeneratorType,T> {
    return MapSequenceGenerator(
      _base: _base.generate(), _transform: _transform)
  }
  
  var _base: Base
  var _transform: (Base.GeneratorType.Element)->T
}

@public struct MapCollectionView<Base: Collection, T> : Collection {
  @public var startIndex: Base.IndexType {
    return _base.startIndex
  }
  
  @public var endIndex: Base.IndexType {
    return _base.endIndex
  }

  @public subscript(index: Base.IndexType) -> T {
    return _transform(_base[index])
  }

  @public func generate() -> MapSequenceView<Base, T>.GeneratorType {
    return MapSequenceGenerator(_base: _base.generate(), _transform: _transform)
  }

  var _base: Base
  var _transform: (Base.GeneratorType.Element)->T
}

@public func map<S:Sequence, T>(
  source: S, transform: (S.GeneratorType.Element)->T
) -> MapSequenceView<S, T> {
  return MapSequenceView(_base: source, _transform: transform)
}

@public func map<C:Collection, T>(
  source: C, transform: (C.GeneratorType.Element)->T
) -> MapCollectionView<C, T> {
  return MapCollectionView(_base: source, _transform: transform)
}
