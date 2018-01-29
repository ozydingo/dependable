module NiceAssets
  class AssetRoster
    attr_reader :workflow, :cache

    def initialize(workflow)
      @workflow = workflow
      @cache = {}
    end

    def fetch(label, reload = false)
      return @cache[label] if !reload && @cache.key?(label)
      @cache[label] = case workflow.manifest.node_type(label)
      when "asset" then spec(label).find_asset(@workflow.owner)
      when "checkpoint" then @workflow.evaluate_callback(spec(label))
      end
    end

    def clear
      @cache = {}
    end

    def find_or_initialize_asset(label)
      fetch(label)
      @cache[label] ||= spec(label).initialize_asset(@workflow.owner)
    end

    def find_or_create_asset(label)
      fetch(label)
      @cache[label] ||= spec(label).create_asset(@workflow.owner)
    end

    def spec(label)
      workflow.manifest.spec(label) or raise "No asset specified for #{label} (#{label.class})"
    end
  end
end
