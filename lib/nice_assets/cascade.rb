module NiceAssets
  class Cascade
    extend Cascadable
    attr_reader :points

    def initialize(*points)
      points.each{|label| validate_label(label)}
      @points = points.map{|asset| [asset, true]}.to_h
    end

    def sequence
      self.class.sequence
    end

    def required
      sequence.select{|label, point| point.required?}
    end

    # Cascade points that are required to reach finish and ready to request
    def next_points
      remaining_points.select{|label| prereqs_ready?(label)}
    end

    # All cascade points that are ready to process right now
    def available_points
      sequence.keys.select{|label| prereqs_ready?(label)}
    end

    def point_ready?(label)
      validate_label(label)
      @points.key?(label)
    end

    def prereqs_ready?(label)
      validate_label(label)
      prereqs(label).all?{|prereq| point_ready?(prereq)}
    end

    # Resolved prerequisites for given label
    def prereqs(label)
      validate_label(label)
      sequence[label].prereqs.map{|reqspec| resolve_prereq(reqspec)}.compact
    end

    # Prerequisites not yet ready for asset label
    def remaining_prereqs(label)
      prereqs(label).select{|prereq| !point_ready?(prereq)}
    end

    # Minimal remaining asset labels needed to reach required points
    def remaining_points
      remaining = []
      queue = required.keys.select{|label| !point_ready?(label)}
      while label = queue.shift
        remaining << label
        queue |= remaining_prereqs(label) - remaining
      end
      return remaining
    end

    private

    def validate_label(label)
      label.is_a?(Symbol) or raise ArgumentError, "Label must be a Symbol"
      sequence.key?(label) or raise ArgumentError, "Unrecognized asset label: #{label}"
    end

    def resolve_prereq(reqspec)
      case reqspec
      when Symbol then reqspec
      when Proc then send(reqspec.call)
      when Hash then evaluate_conditional_prereq(reqspec)
      else raise "Invalid asset requirement for #{self}: #{reqspec}. Must be a Symbol, Proc, or Hash!"
      end
    end

    def evaluate_conditional_prereq(reqspec)
      match = req.keys.find{|condition| condition == "else" || public_send(condition)}
      return match && req[match]
    end
  end
end
