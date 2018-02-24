Object.send(:remove_const, :TranscriptionWorkflow) if defined?(TranscriptionWorkflow)
class TranscriptionWorkflow < NiceAssets::AssetWorkflow
  owned_by Service

  asset :source, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false
  checkpoint :audio_input_ready?
  asset :audio, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :audio_input_ready?, class_name: "DspAudio"
  asset :asr, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :audio, class_name: "AsrOutput"
  asset :stream, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :source, class_name: "StoeStream"
  asset :transcript, after: [:asr, :stream], class_name: "TranscribedTranscript"
  asset :caption, ->(s){ where threeplay_transcript_id: s.output_transcript.id }, foreign_key: false, after: :transcript, class_name: "ThreeplayCaption", ignore: :ignore_caption?

  outputs :transcript, :caption

  def request_asset(label)
    puts "DEBUG: requesting #{label}"
  end

  def ignore_caption?
    Random.rand < 0.5
  end

  def audio_input_ready?
    asset_ready?(:source) || asset_ready?(:stream)
  end
end

Service
class Service < ActiveRecord::Base
  extend NiceAssets::ActiveWorkflow
  self::NiceWorkflow = nice_assets do
    asset :source, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false
    checkpoint :audio_input_ready?
    asset :audio, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :audio_input_ready?, class_name: "DspAudio"
    asset :asr, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :audio, class_name: "AsrOutput"
    asset :stream, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :source, class_name: "StoeStream"
    asset :transcript, after: [:asr, :stream], class_name: "TranscribedTranscript"
    asset :caption, ->(s){ where threeplay_transcript_id: s.output_transcript.id }, foreign_key: false, after: :transcript, class_name: "ThreeplayCaption", ignore: :ignore_caption?

    outputs :transcript, :caption
  end
end
