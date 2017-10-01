class TranscriptionService < ActiveRecord::Base
  include NiceAssets::ActiveWorkflow

  has_one :source, through: :media_file
  has_one :stream

  define_assets do
    asset :source
    asset :stream, owner: :media_file
    asset :transcript, ->(owner){ where language_id: owner.media_file.language_id }
    asset :audio, owner: :media_file, ->(myself){ where language_id: myself.media_file.language_id }
    asset :cc_encoding
  end

  define_workflow do
    process :stream, after: :source
    process :audio, after: {:source_available? => :source, :else => :stream}, required: false
    process :audio, after: ->{:audio_input}, required: false
    process :transcript, after: [:stream, :audio]
    process :cc_encoding, :if => :cc_encoding_requested?

    outputs :transcript, :cc_encoding
  end

  def source_available?
  end

  def cc_encoding_requested?
  end

  def audio_input
    source_available? ? :source : :stream
  end
end

class TranscriptionService < ActiveRecord::Base
  has_one :source
  has_many :streams
  has_one :audio
  has_one :transcript

  def workflow
    TranscriptionWorkflow.new(workflow_assets, workflow_options)
  end

  def workflow_assets
    {
      source: self.source,
      stream: self.streams.find{|s| s.streamable?},
      audio: self.audio,
      transcript: self.transcript,
      cc_encoding: self.streams.find{|s| s.has_cc?},
    }
  end

  def workflow_options
    {cc_encoding_requested: self.include_cc_encoding?}
  end


end
