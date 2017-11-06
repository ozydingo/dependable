module NiceAssets
  class ActiveWorkflow
    class << self
      attr_reader :commish, :workflow
      attr_accessor :source_klass

      def inherited(child)
        child.initialize_workflow(self)
      end

      def initialize_workflow(parent)
        # @commish = ::NiceAssets::Commish.new(parent.commish)
        @workflow = ::NiceAssets::Workflow.new(parent.workflow)
        @source_klass = parent.source_klass
      end
    end

    def initialize(record)
      @record = record
    end

    def resume
    end
  end
end
