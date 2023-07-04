# Decide 

- [x] Environment
- [] Observable State
    - [] Atomic State
    - [] Keyed State
    - [] Computed/Selector
    - [] Keyed Computed/Selector
- [] State Access
    - [] SwiftUI
        - [Bind]
        - [???] -> immutable bind
    - [] NonSwiftUI
- [] State Mutation
    - [] Mutable 
    - [] Decisions
- [] Side effects
    
- [] Telemetry
    - [] Context


# Decide Testing
- a library that makes testing of Decide based code easier by providing convenient syntax sugar. 

# Caveats
2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

can be solved by static analysis tools.
