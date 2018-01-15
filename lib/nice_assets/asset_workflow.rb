module NiceAssets
  class AssetWorkflow
    extend NiceAssets::AbstractInterface

    implements :asset_roster

    attr_reader :owner, :asset_cache

    def initialize(owner)
      @owner = owner
      @asset_cache = {}
    end

    def get_asset(label, reload = false)
      return @asset_cache[label] if !reload && @asset_cache.key?(label)
      @asset_cache[label] = asset_roster.find_asset(@owner, label)
    end

    def get_all_assets(reload = false)
      clear_asset_cache if reload
      asset_roster.listed_assets.map do |label|
        [label, get_asset(label, false)]
      end.to_h
    end

    def clear_asset_cache
      @asset_cache = {}
    end
  end
end
