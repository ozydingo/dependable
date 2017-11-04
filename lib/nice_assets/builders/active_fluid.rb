module NiceAssets
  module ActiveFluid
    extend ActiveSupport::Concern

    module ClassMethods
      def active_workflow(name = "default_workflow", &blk)
        builder = ::NiceAssets::ActiveWorkflowBuilder.new(self)
        const_set("ActiveWorkflow", ::NiceAssets::ActiveWorkflowReader.new(builder).read(&blk))
      end

      # TODO: allow multiple workflows with one "default"
      # store default in the ActiveWorkflow const, rest in a class_attr
    end

    def workflow
      self.class::ActiveWorkflow.new(self)
    end
  end
end
