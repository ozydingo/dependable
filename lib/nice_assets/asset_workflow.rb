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

    def resume
      next_assets.each{|label| request_label(label)}
    end

    def next_assets
      requested = requested_assets.keys
      self.class.output_assets.flat_map do |node|
        self.class.asset_graph.next_nodes_for(node, requested)
      end.uniq.select{|name| asset_pending?(get_asset(name))}
    end

    def requested_assets
      get_all_assets.select{|label, asset| !asset_pending?(asset)}
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

    def find_or_initialize_asset(label)
      get_asset(label)
      @asset_cache[label] ||= self.class.asset_roster.build_asset(@owner, label)
    end

    def find_or_create_asset(label)
      get_asset(label)
      @asset_cache[label] ||= self.class.asset_roster.create_asset(@owner, label)
    end

    def request_label(label)
      # TODO: allow locking to be disabled to customized (i.e. different asset guardian)
      asset = @owner.with_lock{ find_or_create_asset(label) }
      request_asset(asset)
    end

    def request_asset(asset)
      asset.request_processing
    end

    def assets_finished?
      get_all_assets.all?{|label, asset| asset_ready?(asset)}
    end
  end
end
