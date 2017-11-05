class TranscriptionWorkflow < NiceAssets::Workflow
  reference :source
  link :stream, after: :source
  link :audio, after: ->{:audio_input}
  output :transcript, after: [:stream, :audio]

  def audio_input
    source_available? ? :source : :stream
  end

  def source_available?
    assets[:source] && !assets[:source].archived?
  end
end

require 'hashie'

class MockAsset < Hashie::Mash
  include NiceAssets::Asset

  def initialize(attrs = {})
    default_attrs = {
      ready?: true,
      archived?: false,
      requestable?: true,
      processing?: true,
      finished?: true,
      failed?: true
    }
    super(default_attrs.merge(attrs))
  end
end

asset = MockAsset.new
