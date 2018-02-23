# Nice Assets

Easily define and manage a complex network / workflow of long-processing assets and their dependencies

Nice Assets allows you to define "workflows" on "owner" objects (for now, ActiveRecord is required) that formalize a set of instructions for how to asynchronously process multiple assets (e.g. processing videos, processing text, performing any long-running background tasks,or sending jobs to external vendors). Nice Assets allows you to very simply define any dependencies between these assets so that they are all processed in the specified order (which can include processing multiple assets in parallel). With NiceAssets, for a given `owner` object with a defined workflow, your application can simply call `owner.resume` at any point in the workflow and have the workflow perform any necessary actions at that point. You can additionally define callbacks that are called with the start or finish of specific assets or upon finishing all assets of the workflow.

## An example

This description is intentionally a little abstract, since the goal of Nice Assets is to provide a highly generalized framework for defining a somewhat complex system. So let's start with an example.

Let's say your application is responsible for processing video and doing several things with it. Specifically, a user uploads a source video file. From this, you transcode this into a standard format, extract the audio, run a signal processing algorithm that cleans up the audio (e.g. isolating speech from other noise), and, finally, you host a streamable version of this video that can be switched from the original to cleaned version on a web server.

<!-- TODO: example code once the block syntax is finalized -->

## NiceAssets components
### AssetSpecification
Defines how to find, create, and request and asset.
### AssetRoster
A list of AssetSpecifications and processing callbacks for each.
### AssetGraph
The arrangement of asset processing dependencies. Knows which assets depend on the completion of which other assets, and needs only to know which assets are ready, but knows nothing about asset processing or callbacks.
### AssetWorkflow
Contains an AssetGraph and an AssetRoster and is initialized with an `owner`. Manages all calls to the graph to determine the current workflow status and what the next workflow steps are, and the roster to find or create any needed assets.
### AssetRoster
A simple cache of existing 
