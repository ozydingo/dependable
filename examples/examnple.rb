class TranscriptionSequence < NiceAssets::Sequence
  process :source
  process :stream, after: :source
  process :audio, after: ->{:audio_input}, required: false
  process :transcript, after: [:stream, :audio]
  process :cc_encoding, :include_if => :cc_encoding_requested?

  def audio_input
    source_available? ? :source : :stream
  end

  def source_available?
    assets[:source].present? && !assets[:source].archived?
  end

  def cc_encoding_requested?
    options[:cc_encoding]
  end
end
