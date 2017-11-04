class Transcript < ActiveRecord::Base
  extend NiceAsset:ActiveFluid
  active_workflow(:jobs) do
    asset :edit_job
    asset :qa_job, skip_if: :skip_qa?
  end
end

class TranscriptionService
  lifecycle do
    after_start ->(s) {s.asset_manager.request_asset(:source)}
    after_cancel :remove_available_jobs, :close_all_omm_tasks
    after_reject :remove_available_jobs, :close_all_omm_tasks
    after_finish :record_missed_deadline, :close_all_omm_tasks
  end

  has_one :source
  has_one :dsp_audio
  has_one :asr_audio
  has_one :stoe_stream
  has_one :stoe_volume_stream
  has_one :asr_output
  has_asset :asr_transcript, ->(s){where(language_id: s.language.id)}
  has_one :qt_audio
  has_asset :transcribed_transcript, ->(s){where(service_id: s.id, language_id: s.media_file.language_id)}
  has_asset :threeplay_caption, ->(s){ where(threeplay_transcript_id: s.output_transcript.id) }

  asset_workflow do
    input :source
    process :dsp_audio, after: :source
    process :asr_audio, after: :dsp_audio
    output :stoe_stream, after: :source, as: :output
    process :stoe_volume_stream, after: :stoe_stream
    process :asr_output, after: :asr_audio
    process :asr_transcript, after: :asr_output do
      on_finish :handle_asr_transcript
    end
    process :qt_audio, after: :source
    process :transcribed_transcript, as: :output, after: [:asr_transcript, :stoe_stream] do
      on_request :start_caption_placement_service
      on_finish :postprocess_output_transcript
    end
    process :threeplay_caption, as: :output, after: :transcribed_transcript do
      on_finish  :deliver_assets, :if => :finished?
    end
  end

end

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
    process :transcript, after: [:stream, :audio] do
      before_request: :get_pumped
      after_finish: :pump_it
    end
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
