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
Decide also eliminates the need for dependency injection anywhere but effects and some services [and provides tools](#dependency-injection) to define `DefaultInstance` as a variation of property and access it with `Instance` property wrapper to obtain the instance. 


Additionaly **DecideTesting** provides tools to replace the environment and track execution in tests, allowing for the implementation of functionality tests (black box testing) as easily as unit tests. For more information on the mentioned APIs, you can refer to the official Apple documentation for , 


## Decision

## Effect

## Dependency Injection


# Decide 

Decide designed to manage state and side-effects, specifically tailored for Swift developers. It is compatible with SwiftUI, but it goes a step further by extending state management beyond the SwiftUI view context. 

The library addresses some of the limitations found [in SwiftUI's `@State` and `Binding`](https://developer.apple.com/documentation/swiftui/binding) and [Combine's @Published](https://developer.apple.com/documentation/combine/published/) approach, providing a solution for defining state outside of a SwiftUI view, a feature that is currently lacking in SwiftUI. 

Moreover, "Decide" offers a solution for unidirectional state updates and side-effect management, another area where SwiftUI falls short. Importantly, the library is not limited to SwiftUI and can be used in any non-SwiftUI code. 

## Key Features

- **SwiftUI Compatibility:** Decide is designed to seamlessly integrate with SwiftUI, enhancing its state management capabilities beyond the SwiftUI view context.

- **State Declaration:** This feature decouples state declarations from view contexts, providing a way to declare them independently. Unlike `@Published` or `@State`, it doesn't require an instance of the ViewModel or View. Instead, it uses environment and KeyPaths to access the value.
    - It offers `AtomicState` or `KeyedState` classes for group ability and `@Property` to define the name, type, and default value of the state, which is an extended version of SwiftUI's `@State`.
    - It supports both mutable and immutable properties.
    - It introduces `Computation`, a type of state that is computed based on other states and is recomputed when one or more of them change.
    - Keyed States allow for the creation of atomic states that can differentiate based on a `Key`. This is ideal for lists or collections of items that are identical but differentiated by ID or any other key.

## How to Use

### Declaring State

Decide introduces `@Property` as a way to describe the atomic observable value in the environment. This is similar to SwiftUI's `@State`, but it allows for a more atomic standalone state definition:

```swift
final class TodoList: AtomicState {

    // \.TodoList.$networking <- property key path
    @DefaultInstance var networking: Networking = URLSession.shared
    
    // \.TodoList.$selectedItemID <- property key path
    @Property var selectedItemID: Item.ID?
    

    /// Nested keyed state 
    final class FeatureFlag: KeyedState<String> {
        // \.TodoList.FeatureFlag.$isEnabled <- property key path
        // requires access by id e.g. isEnabled[id]
        @Property var isEnabled: Bool = false
    }
}
```

## Nesting
You can nest state declarations to better define your state by creating a new state within another one or extending it. This doesn't have any effect other than a name change. So, if you decide to restructure your state later, you only need to move properties where they belong and update keypaths that have been used.

### Keyed State

`KeyedState` is an enhancement for cases where the state is atomic but differentiates depending on a `Key`, such as a list of products, each with its own unique ID. This state is accessed like a dictionary:

```swift

@Bind(\TodoList.FeatureFlag.$isEnabled) var isFeatureEnabled

var body: some View {
    if isFeatureEnabled[myFeatureName] {
        ...
    }
}

```


# Decide Testing
- a library that makes testing of Decide-based code easier by providing convenient syntax sugar. 
- [ ] Recursive Override Of Environment


# Caveats
2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

can be solved by static analysis tools.
