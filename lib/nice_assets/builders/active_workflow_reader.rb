module NiceAssets
  class ActiveWorkflowReader < BasicObject
    def initialize(builder)
      @builder = builder
    end

    def read(&blk)
      instance_exec(&blk)
      return @builder.workflow_klass
    end

    def before_resume(*callbacks)
      callbacks.each do |callback|
        @builder.add_callback(callback)
      end
    end

    # TODO: explicitify method signature
    def asset(name, *opt)
      @builder.add_asset(name, *opts)
    end
  end
end
