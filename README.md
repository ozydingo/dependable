Roadmap handle navigation of assets -- knows the map, and what comes next. No knowledge of state or the asset interface
Workflow uses the workflow to request assets in sequence. Expects assets to have a standard interface. No knowledge ot ActiveRecord or any db backing.
Commissioner knows how to find and create asset records in ActiveRecord. Passes persisted or new asset objects to the commissioner.

