module NiceAssets
  class ActiveWorkflowReader < BasicObject
    def initialize(builder)
      @builder = builder
    end

    def read(&blk)
      instance_exec(&blk)
      return @builder.workflow_klass
    end

    def before_start(*callbacks)
      @builder.add_workflow_callbacks(:start, :before, *callbacks)
    end

    def after_start(*callbacks)
      @builder.add_workflow_callbacks(:start, :after, *callbacks)
    end

    def before_finish(*callbacks)
      @builder.add_workflow_callbacks(:finish, :before, *callbacks)
    end

    def after_finish(*callbacks)
      @builder.add_workflow_callbacks(:finish, :after, *callbacks)
    end

    def before_resume(*callbacks)
      @builder.add_workflow_callbacks(:resume, :after, *callbacks)
    end

    def after_resume(*callbacks)
      @builder.add_workflow_callbacks(:resume, :after, *callbacks)
    end

    def before_asset_request(label, *callbacks)
      @builder.add_asset_callback(label, :request, :before, *callbacks)
    end

    def after_asset_request(label, *callbacks)
      @builder.add_asset_callback(label, :request, :after, *callbacks)
    end

    def before_asset_finish(label, *callbacks)
      @builder.add_asset_callback(label, :finish, :before, *callbacks)
    end

    def after_asset_finish(label, *callbacks)
      @builder.add_asset_callback(label, :finish, :after, *callbacks)
    end

    # TODO: explicitify method signature
    def asset(name, *opt)
      @builder.add_asset(name, *opts)
    end


  end
end
