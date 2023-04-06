**WIP: If you see this I screwed up and forgot to update readme before publishing :D**


# Decide 

- [x] Context
- [x] Telemetry
- [x] Storage Key
- [x] Observation
- [x] Storage
    - [x] Reader - `CallAsFunction<Value>(key) -> Value` + tests
    - [x] Writer - `CallAsFunction<Value>(key) -> Value` + tests
    - [x] Decision 
    - [x] Effect
    - [x] NoOperation
    - [ ] Tracing
- [ ] Environment
    - Decision Execution
    - Effect Execution
    - NoOp termination
    - Tracing
    - Performance testing
    - ??? Loop detection
- [ ] Atomic State Type
- [ ] Observe
- [ ] 

# Version 2
- [ ] Learn more about SPM package plugins, to enable tooling that can be run on build phase.
    - [ ] Computation loop detection:
        - A -> B -> C -> A dependency loop
    - [ ] Effect decision loop detection (e.g. never terminates)
        - Static analysis on whad decisions and effect.s each return, and whether it's possible to exit. e.g. A -> EA,  B -> EB, EA -> B, EB -> A, we need to check if A, B, EA, EB, either of them has a NoOp as a possible return value based on the static analysis 

/

# Two Caveats
1. URI based keys: It's easy to create two states that have different Value type, but still the same URI.
Which would lead to Value type mismatch when reading from storage.

2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

Both of them can be solved by static analysis tools.
  
# Telemetry 
see [Doc](doc:/telemetry)
