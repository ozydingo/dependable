module NiceAssets
  class AssetRoster
    attr_reader :owner, :specs, :cache
    def initialize(owner, specs)
      @owner = owner
      @specs = specs
      @cache = {}
    end

    def fetch(label, reload = false)
      return @cache[label] if !reload && @cache.key?(label)
      @cache[label] = spec(label).find_asset(@owner)
    end

    def clear
      @cache = {}
    end

    def find_or_initialize_asset(label)
      fetch(label)
      @cache[label] ||= spec(label).initialize_asset(@owner)
    end

    def find_or_create_asset(label)
      fetch(label)
      @cache[label] ||= spec(label).create_asset(@owner)
    end

    def spec(label)
      @specs[label] or raise "No asset specified for #{label} (#{label.class})"
    end
  end
end
