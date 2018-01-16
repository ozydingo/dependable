require "nice_assets/asset_workflow_class_methods.rb"

module NiceAssets
  class AssetWorkflow
    extend NiceAssets::AssetWorkflowClassMethods

    attr_reader :owner, :asset_cache

    def initialize(owner)
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
  end
end
