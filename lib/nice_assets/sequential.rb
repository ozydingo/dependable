module NiceAsset
  module Sequential
    def sequence
      base? ? {} : superclass.sequence.merge(@sequence)
    end

    def process(label, required: true, after: [], wait_until: nil, include_if: nil)
      asset_spec = ::NiceAssets::AssetSpecification.new(label, required: required, prereq: after, wait_until: wait_until, include_if: include_if)
      asset_spec.known_prereq_labels.each{|label| validate_label(label)}
      @sequence[asset_spec.label] = asset_spec
    end

    protected

    def inherited(child)
      child.initialize_sequence
      super
    end

    def initialize_sequence
      @sequence = {}
    end

    def base?
      self == ::NiceAssets::Sequence
    end

    def validate_label(label)
      sequence.key?(label) or raise ArgumentError, "Unrecognized asset labels: #{label}"}
    end
  end
end
