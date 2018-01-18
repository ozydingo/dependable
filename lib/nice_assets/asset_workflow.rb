require "nice_assets/asset_workflow_class_methods.rb"

module NiceAssets
  class AssetWorkflow
    extend NiceAssets::AssetWorkflowClassMethods

    attr_reader :owner, :asset_cache

    def initialize(owner)
      owner.is_a?(self.class.owner_class) or raise TypeError, "Wrong owner for #{self.class}: expected #{self.class.owner_class}, got #{owner.class}"
      @owner = owner
      @asset_cache = {}
    end

    def get_asset(label, reload = false)
      return @asset_cache[label] if !reload && @asset_cache.key?(label)
      @asset_cache[label] = self.class.asset_roster.find_asset(@owner, label)
    end

    def get_all_assets(reload = false)
      clear_asset_cache if reload
      self.class.asset_roster.listed_assets.map do |label|
        [label, get_asset(label, false)]
      end.to_h
    end

    def clear_asset_cache
      @asset_cache = {}
    end

    def next_assets
      self.class.output_assets.flat_map do |node|
        self.class.asset_graph.next_nodes_for(node, completed_assets.keys)
      end.uniq.select{|name| asset_pending?(get_asset(name))}
    end

    def completed_assets
      get_all_assets.select{|label, asset| asset_ready?(asset)}
    end

    def asset_pending?(asset)
      asset.nil? || asset.pending?
    end

    def asset_ready?(asset)
      asset.try!(:ready?)
    end
  end
end
