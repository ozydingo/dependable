AssetSpecification: Defines how to find, create, and request and asset.

AssetRoster: List of AssetSpecifications and processing callbacks for each.

AssetGraph: Arrangement of asset processing dependencies. Needs only to know which assets are ready, nothing about processing or callbacks.
 -- Q: Can an AssetGraph be dynamic, or should we switch between static AssetGraphs?
 -- Does not need sense of "required" or "output" assets; caller can ask "next assets for (outputs)"

 AssetWorkflow: contains an AssetGraph and an AssetRoster. Initializes with any needed resources (e.g. a Service instance). Calls its AssetRoster to find its current assets. Calls its AssetGraph to determine what's next. Calls the AssetRoster again to create and request necessary assets.
