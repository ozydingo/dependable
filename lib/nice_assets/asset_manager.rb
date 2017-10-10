module NiceAssets
  class AssetManager
    @asset_seekers = {}
    @asset_cache = {}
    @asset_callbacks = []

    class << self
      attr_accessor :asset_specifications, :asset_seekers, :asset_callbacks
      protected :asset_specifications=, :asset_seekers=, :asset_callbacks=

      def inherited(child)
        child.asset_specifications = @asset_specifications.deep_dup
        child.asset_seekers = @asset_seekers.deep_dup
        child.asset_callbacks = @asset_callbacks.deep_dup
      end
    end

    # resume / request next assets
    # determine asset requestability
    # abort assets
    # asset callbacks
    # lifecycle callbacks

    attr_reader :workflow, :asset_cache

    def initialize(workflow, **asset_seekers)
      workflow.is_a?(NiceAssets::Workflow) or raise TypeError, "Expected NiceAssets::Workflow, got #{workflow.class}"
      @workflow = workflow
    end

    def resume_workflow
      perform_lifecycle_callbacks("resume", "before")
      perform_lifecycle_callbacks("resume", "after")
    end

    def fail_workflow
      perform_lifecycle_callbacks("fail", "before")
      perform_lifecycle_callbacks("fail", "after")
    end

    def request_asset(label)
      perform_asset_callbacks(label, "request", "before")
      perform_asset_callbacks(label, "request", "after")
    end

    def handle_finished_asset(asset)
      perform_asset_callbacks(label, "finish", "before")
      perform_asset_callbacks(label, "finish", "after")
    end

    def handle_failed_asset(asset)
      perform_asset_callbacks(label, "fail", "before")
      perform_asset_callbacks(label, "fail", "after")
    end

    def requestables
      workflow.next_nodes.select{|label| node.requestable?}
    end

    def request_asset(label)
      workflow.validate_label(label)
      seeker = asset_seekers[label]
      asset = seeker
    end

    private

    def perform_asset_callbacks(label, event, position)
    end

    def perform_lifecycle_callbacks(event, position)
    end

  end
end
