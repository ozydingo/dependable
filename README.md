Roadmap handle navigation of assets -- knows the map, and what comes next. No knowledge of state or the asset interface (ax?)

Workflow
  - Define which assets get requested when, and handles requesting.
  - No knowledge of ActiveRecord or db: Initialize with labeled assets.
  - Supports assets being non-NiceAssets for workflow mapping but will refuse to request them (subsumes more naive Roadmap model).
  - Can define lifecycle events: start, resume, finish, request(label), finish(label), fail(label)

AssetPimp
  - Knows where to find its assets using ActiveRecord

ActiveWorkflow
  - Uses a Workflow and an AssetPimp to provide a single clean interface to integrating a Workflow into an ActiveRecord model

Primary Use Case:

Service (include ActiveWorkflow)
  - define asset associations
  - define workflow
  - start_processing:
    - perform start callbacks
    - resume workflow
  - resume workflow:
    - perform workflow resume callbacks
  - resume workflow until workflow.finished?
  - perform finish callbacks
