assoc = SelfishAssociations::Associations::HasOne.new("source", Service, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false)
spec = NiceAssets::AssetSpecification.new(assoc)
