module NiceAssets
  module ActiveWorkflow
    extend ActiveSupport::Concern
    extend NiceAssets::AbstractInterface

    implements :workflow_assets
    implements :workflow_options

    def resume_assets
      need_next = workflow.next_nodes
      need_next.select{|label| workflow_assets[label].blank?}.each{|label| create_asset(label)}
      commissioner.request_next_assets
    end

    def workflow
      self.class::Workflow.new(workflow_assets, workflow_options)
    end

    module ClassMethods
      def define_assets(&blk)
        define_method :workflow_assets do
        end
      end

      def define_workflow(&blk)
        class Workflow < NiceAssets::Workflow
          instance_eval(&blk)

          def method_missing(name)
            # ??
          end
        end
      end
    end
  end
end
