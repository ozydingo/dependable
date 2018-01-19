module NiceAssets
  class AssetRoster
    def initialize
      @roster = {}
    end

    def add_spec(label, asset_spec)
      !listed?(label) or raise "Already defined spec for #{label}"
      @roster[label] = asset_spec
    end

    def find_asset(owner, label)
      validate_listed(label)
      @roster[label].find_asset(owner)
    end

    def build_asset(owner, label)
      validate_listed(label)
      @roster[label].initialize_asset(owner)
    end

    def create_asset(owner, label)
      validate_listed(label)
      @roster[label].create_asset(owner)
    end

    def find_all_assets(owner)
      @roster.map do |label, spec|
        [label, spec.find_asset(owner)]
      end.to_h
    end

    def listed_assets
      @roster.keys
    end

    def listed?(label)
      @roster.key?(label)
    end

    def spec(label)
      @roster[label]
    end

    def validate_listed(label)
      listed?(label) or raise "No asset with label #{label} (#{label.class})."
    end
  end
end
