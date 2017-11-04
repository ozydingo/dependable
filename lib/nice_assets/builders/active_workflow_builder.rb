module NiceAssets
  class ActiveWorkflowBuilder
    attr_reader :source_klass, :workflow_klass
    def initialize(source_klass)
      @source_klass = source_klass
      @workflow_klass = Class.new(workflow_superclass)
      @workflow_klass.source_klass = @source_klass
    end

    def workflow_superclass
      if defined? @source_klass::ActiveWorkflow
        @source_klass::ActiveWorkflow
      else
        ::NiceAssets::ActiveWorkflow
      end
    end

    def add_callback(callback)
      @workflow_klass
    end

    def add_asset(asset, **opts)
      @workflow_klass
    end
  end
end
