**WIP: If you see this I screwed up and forgot to update readme before publishing :D**


# Decide 

- [x] Context
- [x] Telemetry
- [x] Storage Key
- [x] Observation
- [x] Storage
- [x] Reader
- [x] Writer
- [x] Decision 
- [x] Effect
- [x] NoOperation    
- [x] Environment
    - Decision Execution
    - Effect Execution
    - NoOp termination    
- [x] Atomic State Type
- [ ] Observe
- [ ] Integration Testing for Atomic using views and Observe
    - [ ] Performance testing (?)
- [ ] Tracing
    - [ ] Tracing testing    
- [ ] Review and create a release plan. 

# Version 1
- TestEnvironment - saves effects and decisions ??? or XCTMEtrics and read logs?
    - await execution() -> wait's untel aal effects and decisions return noop


# Version 2
- [ ] Learn more about SPM package plugins, to enable tooling that can be run on build phase.
    - [ ] Computation loop detection:
        - A -> B -> C -> A dependency loop
    - [ ] Effect decision loop detection (e.g. never terminates)
        - Static analysis on whad decisions and effect.s each return, and whether it's possible to exit. e.g. A -> EA,  B -> EB, EA -> B, EB -> A, we need to check if A, B, EA, EB, either of them has a NoOp as a possible return value based on the static analysis 
# Tooling
- DecideCoreData - integration with coredata like FetchRequest etc
- DecideUIComponents - Design system base, with colors fonts and components that can use state-types?? and/or of bindings
- DecideCloudKit - integration with CloudKit to sync storage and test Cloud integration
- DecideRequest - URL request building library, may be utilixze the result builder
- OpenTelementry standart Tracing
- Instruments on steroids 

# Two Caveats
1. URI based keys: It's easy to create two states that have different Value type, but still the same URI.
Which would lead to Value type mismatch when reading from storage.

2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

Both of them can be solved by static analysis tools.
  
# Telemetry 
see [Doc](doc:/telemetry)
