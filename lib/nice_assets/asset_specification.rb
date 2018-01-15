module NiceAssets
  class AssetSpecification
    def initialize(assoc)
      @assoc = assoc
    end

    def attributes_for(owner)
      # TODO: don't hack into the private methods
      @assoc.send(:instance_find_conditions, owner)
    end

    def asset_class
      @assoc.foreign_class
    end

    def match?(asset, owner)
      # TODO: be a little more judicious than just hitting "send" (e.g. :delete??)
      asset.is_a?(asset_class) && attributes_for(owner).all?{|field, value| asset.send(field) == value}
    end

    def find_asset(owner)
      @assoc.matches_for(owner).last
    end

    def initialize_asset(owner)
      @assoc.initialize_for(owner)
    end

    def create_asset(owner)
      @assoc.create_for(owner)
    end

    def find_or_initialize_asset
      find_asset || initialize_asset
    end

    def find_or_create_asset
      asset = find_or_initialize_asset
      asset.save!
      return asset
    end
  end
end
