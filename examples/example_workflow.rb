class TranscriptionWorkflow < NiceAssets::Workflow
  process :source
  process :stream, after: :source
  process :audio, after: ->{:audio_input}, required: false
  process :transcript, after: [:stream, :audio]

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

  def initialize(hash)
    super(hash.reverse_merge(
      ready?: true,
      archived?: false,
      :requestable?: true
      :processing?: true
      :finished?: true
      :failed?: true
    ))
  end
end
