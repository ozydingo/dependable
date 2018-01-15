class TxWorkflow < NiceAssets::AssetWorkflow
  def source_spec
    source_assoc = SelfishAssociations::Associations::HasOne.new("source", Service, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false)
    source_spec = NiceAssets::AssetSpecification.new(source_assoc)
  end

  def tx_spec
    tx_assoc = SelfishAssociations::Associations::HasOne.new("transcribed_transcript", Service)
    tx_spec = NiceAssets::AssetSpecification.new(tx_assoc)
  end

  def asset_roster
    roster = NiceAssets::AssetRoster.new
    roster.add_spec(:source, source_spec)
    roster.add_spec(:transcript, tx_spec)
    return roster
  end
end

graph = NiceAssets::AssetGraph.new
graph.add_node(:source)
graph.add_node(:audio, after: :source)
graph.add_node(:stream, after: :audio)
graph.add_node(:asr, after: :audio)
graph.add_node(:tx, after: [:asr, :stream])
