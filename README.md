[![Unit Tests](https://github.com/MaximBazarov/Decide/actions/workflows/swift-build-test.yml/badge.svg)](https://github.com/MaximBazarov/Decide/actions/workflows/swift-build-test.yml)
___

Decide is state and side effect management library. 
It is compatible with SwiftUI, but also extends state management beyond the SwiftUI view context, and can be used in any non-SwiftUI code.
Addresses some of the limitations found in SwiftUI's [`@State`](https://developer.apple.com/documentation/swiftui/state), [`Binding`](https://developer.apple.com/documentation/swiftui/binding), and [`@Published`](https://developer.apple.com/documentation/combine/published) approaches, 
providing solutions for unidirectional state updates and side-effect management, an area where SwiftUI falls short. 

Decide offers a way to define observable states outside of a SwiftUI view and provides a convenient method to separate state updates from the side effects they cause.
 
This is achieved by introducing the [`Decision`](#decision) and [`Effect`](#effect) abstractions, which are designed to define state mutations and execute side effects.
These abstractions are more effective for modularization compared to the UseCase/Operation or Action/Reducer/Effect models. 
They offer a more intuitive approach to business requirements, thereby enhancing the overall coding process. 
Decide also eliminates the need for dependency injection anywhere but effects and some services [and provides tools](#dependency-injection) to define `DefaultInstance` as a variation of observableState and access it with `Instance` observableState wrapper to obtain the instance. 


Additionaly **DecideTesting** provides tools to replace the environment and track execution in tests, allowing for the implementation of functionality tests (black box testing) as easily as unit tests. 


## Decision

## Effect

## Dependency Injection

# Decide Testing
A library that makes testing of Decide-based code easier by providing convenient syntax sugar. 

# Caveats
2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

can be solved by static analysis tools.
