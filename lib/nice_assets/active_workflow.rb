module NiceAssets
  module ActiveWorkflow
    def nice_assets(delegate: true, &blk)
      workflow = Class.new(NiceAssets::AssetWorkflow)
      workflow.include NiceAssets::WorkflowDelegator if delegate
      workflow.owned_by(self)
      workflow.instance_eval(&blk)
      return workflow
    end
  end
end
