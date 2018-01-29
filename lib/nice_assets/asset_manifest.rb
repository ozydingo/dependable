module NiceAssets
  class AssetManifest
    attr_reader :list

    def initialize
      @list = {}
    end

    def node_type(name)
      @list[name] && @list[name][:type]
    end

    def asset?(name)
      node_type(name) == "asset"
    end

    def checkpoint?(name)
      node_type(name) == "checkpoint"
    end

    def spec(name)
      @list[name] && @list[name][:spec]
    end

    def listed?(name)
      @list.key?(name)
    end

    def assets
      @list.select{|name, item| item[:type] == "asset"}
    end

    def asset_names
      assets.keys
    end

    def checkpoints
      @list.select{|name, item| item[:type] == "checkpoint"}
    end

    def checkpoint_names
      checkpoints.keys
    end

    def add_asset(name, spec)
      @list[name] = {type: "asset", spec: spec}
    end

    def add_checkpoint(name, spec)
      @list[name] = {type: "checkpoint", spec: spec}
    end
  end
end
