# Decide

Decide is a robust and adaptable library that streamlines the process of modeling application states, managing controlled mutations through well-defined Decisions, and handling side-effects using Effects executed on a shared task pool.


# Features

With composability, modularity, and performance as its core principles, Decide streamlines the process of defining and modularizing your application state. Unlike other solutions that require defining a monolithic state structure, Decide promotes granular state management at the property level, resulting in a highly modular and maintainable approach.


## Simplified Modularization with Atomic States
In Decide, atomic states are used to define individual state properties. This simplifies state management and modularization, as demonstrated in the following Swift example:

**FeatureOneState.swift**
```swift
struct Name: AtomicState {
    func defaultValue() -> String { "Untitled" }
}

struct Messages: CollectionState {
    static func defaultValue(at id: MessageID) -> String { [] }
}

struct MessagesIndex: AtomicState {
    static func defaultValue() -> [MessageID] { [] }
}
```

Comparatively, in traditional solutions, you would define a state structure and import it into every module:

**AppState.swift**
```swift
struct AppState {
   let featureOne: FeatureOneState
   let otherFeature: OtherFeatureState
   ...
}
```

**FeatureOneState.swift**
```swift
struct FeatureOneState {
    let name: String
    let messages: [MessageID: String]
}
```

By embracing Decide's composable approach, you can create a more accessible, organized, and appealing state management solution.


# Effortless State Access

Decide enables effortless state access from anywhere in your application, while respecting access permissions like public, private, etc. You can observe immutable values or bind them with access to mutations as needed:

```swift
struct ContentView: View {
    @Bind(FeatureOne.Name.self) var name
    @Observe(FeatureOne.MessagesIndex) var messageIndex
    @ObserveCollection(FeatureOne.Messages.self) var messages

    var body: some View {
            VStack {
                TextField(text: $name)

                ForEach(messageIndex, id: \.self) { id in
                    Text(messages[id])
                }
            }
}
```

With Decide, the view automatically updates whenever the values involved in rendering the body change, removing the need for manual value comparisons and ensuring efficient state updates.

This ensures optimal performance and seamless state updates, simplifying the process of working with application states.

## Decisions: The Single Mechanism for Controlled State Mutations

Decisions in Decide provide a singular, well-structured method for mutating the state in your application. To define a Decision, follow these two steps:

1. Define how the state should be updated using read and write functions:
```swift
struct AddMessage: Decision {

    let message: MessageResponse

    func execute(read: StorageReader, write: StorageWriter) -> Effect {
        write(message.content, into: Messages.self, at: message.id)
        write(message.id, into: MessagesIndex.self, .append)
        write(.loadingAttachments, into: MessageStatus.self)
    }
    return DownloadMessageAttachment(message)
}
```

In this example, the message received from the backend is added to the storage, and then the downloading of its attachments is initiated on the detached task pool.

2. Invoke the Decision by accessing the execute method from storage or using the convenient wrapper @MakeDecision:
```swift
...
import FeatureOne

@MakeDecision var makeDecision

var body: some View {
    VStack {
        ...
    }
    .onAppear {
        makeDecision(FeatureOne.LoadMessages())
    }
}
```

By following this approach, you can ensure that state mutations are consistently managed and controlled, preventing unexpected behavior and promoting a reliable application state.
