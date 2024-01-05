import DecideMacros

@attached(
    member,
    names: named(environment),
    named(init(environment:))
)
@attached(memberAttribute)
@attached(extension, conformances: StateRoot)
public macro EnvironmentObservable() = #externalMacro(
    module: "DecideMacros",
    type: "StorageMacro"
)
