require "nice_assets/asset_workflow_class_methods.rb"

module NiceAssets
  class AssetWorkflow
    extend NiceAssets::AssetWorkflowClassMethods

    attr_reader :owner, :roster

    def initialize(owner)
      owner.is_a?(self.class.owner_class) or raise TypeError, "Wrong owner for #{self.class}: expected #{self.class.owner_class}, got #{owner.class}"
      @owner = owner
      @roster = NiceAssets::AssetRoster.new(owner, self.class.asset_specs)
    end

    # TODO: prevent race condition calling request twice
    def resume
      @roster.clear
      next_assets.each do |label|
        @owner.with_lock{ @roster.find_or_create_asset(label) }
        request_asset(label)
      end
    end

    def request_asset(label)
      @roster.fetch(label).request_processing
    end

    def next_assets
      remaining = self.class.asset_graph.remaining_nodes_to(self.class.output_assets, self)
      return remaining.select{|node| node_type(node) == "asset" && prerequisites_ready?(node)}
    end

    def prerequisites_ready?(node)
      self.class.asset_graph.prerequisites(node).all? do |node|
        node_ready?(node)
      end
    end

    def node_type(name)
      if self.class.asset_specs.key?(name)
        "asset"
      elsif self.class.checkpoints.key?(name)
        "checkpoint"
      else
        nil
      end
    end

    def node_pending?(name)
      return false if ignore_label?(name)
      case node_type(name)
      when "asset" then asset_pending?(name)
      when "checkpoint" then !checkpoint_complete?(name)
      else raise "No node named #{name} (#{name.class})"
      end
    end

    def node_ready?(name)
      return true if ignore_label?(name)
      case node_type(name)
      when "asset" then asset_ready?(name)
      when "checkpoint" then checkpoint_complete?(name)
      else raise "No node named #{name} (#{name.class})"
      end
    end

    def ignore_label?(label)
      self.class.ignore_conditions.key?(label) && evaluate_callback(self.class.ignore_conditions[label])
    end

    def asset_pending?(label)
      asset = @roster.fetch(label)
      asset.nil? || asset.pending?
    end

    def asset_ready?(label)
      @roster.fetch(label).try!(:ready?)
    end

    def checkpoint_complete?(label)
      evaluate_callback(self.class.checkpoints[label])
    end

    def assets_finished?
      self.class.asset_specs.keys.all?{|label| asset_ready?(label)}
    end

    def evaluate_callback(callback)
      self.send(callback)
    end
  end
end
