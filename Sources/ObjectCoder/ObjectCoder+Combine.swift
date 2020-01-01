#if canImport(Combine)

import Combine

extension ObjectEncoder: TopLevelEncoder {}

extension ObjectDecoder: TopLevelDecoder {}

#endif
