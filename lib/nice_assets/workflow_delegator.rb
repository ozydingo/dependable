module NiceAssets
  module WorkflowDelegator
    def method_missing(name, *args)
      owner.send(name, *args)
    end
  end
end
