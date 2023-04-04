**WIP: If you see this I screwed up and forgot to update readme before publishing :D**


# Decide 

- [x] Context
- [x] Telemetry
- [x] Storage Key
- [ ] Storage
    - [ ] Reader
    - [ ] Writer
    - [ ] Decision 
    - [ ] Effect
    - [ ] NoOperation
- [ ] Observation
- [ ] Atomic State Type
- [ ] Observe
- [ ] 

# Two Caveats
1. URI based keys: It's easy to create two states that have different Value type, but still the same URI.
Which would lead to Value type mismatch when reading from storage.

2. Cyclic computations: easy to make a cycle in Computation's dependencies by reading each other.

Both of them can be solved by static analysis tools.
  
# Telemetry 
see [Doc](doc:/telemetry)
