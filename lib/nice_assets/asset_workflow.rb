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
      nopes = requested_assets | completed_checkpoints | ignored_labels
      next_nodes = self.class.output_assets.flat_map do |node|
        self.class.asset_graph.next_nodes_for(node, nopes)
      end.uniq
      return next_nodes.select{|name| self.class.asset_specs.keys.include?(name) && asset_pending?(name)}
    end

    def checkpoint_value(label)
      return nil if ignore_label?(label)
      evaluate_callback(self.class.checkpoints[label])
    end

    def checkpoint_values
      self.class.checkpoints.map do |label, cond|
        [label, checkpoint_value(label)]
      end.to_h
    end

    def requested_assets
      self.class.asset_specs.keys.select{|label| !asset_pending?(label)}
    end

    def completed_assets
      self.class.asset_specs.keys.select{|label| asset_ready?(label)}
    end

    def completed_checkpoints
      checkpoint_values.select{|label, value| value}.keys
    end

    def ignored_labels
      self.class.ignore_conditions.select{|label, condition| evaluate_callback(condition)}.keys
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

    def assets_finished?
      self.class.asset_specs.keys.all?{|label| asset_ready?(label)}
    end

    def evaluate_callback(callback)
      self.send(callback)
    end
  end
end
