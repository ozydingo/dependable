module NiceAssets
  module Cascadable
    def sequence
      base? ? {} : superclass.sequence.merge(@sequence)
    end

    def cascade(label, after: [], required: true)
      point = ::NiceAssets::CascadePoint.new(label, prereq: after, required: required)
      point.known_prereqs.each{|label| validate_label(label)}
      @sequence[point.label] = point
    end

    def required
      sequence.select{|label, point| point.required?}
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
      self == ::NiceAssets::Cascade
    end

    def validate_label(label)
      sequence.key?(label) or raise ArgumentError, "Unrecognized asset labels: #{label}"
    end
  end
end
