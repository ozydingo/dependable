Object.send(:remove_const, :TranscriptionWorkflow) if defined?(TranscriptionWorkflow)
class TranscriptionWorkflow < NiceAssets::AssetWorkflow
  owned_by Service

  asset :source, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false
  asset :audio, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :source, class_name: "DspAudio"
  asset :asr, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :audio, class_name: "AsrOutput"
  asset :stream, ->(s){ where media_file_id: s.media_file_id }, foreign_key: false, after: :source, class_name: "StoeStream"
  asset :transcript, after: [:asr, :stream], class_name: "TranscribedTranscript", as: "output"

  outputs :transcript
end
