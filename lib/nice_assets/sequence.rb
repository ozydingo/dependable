module NiceAssets
  class Sequence
    extend Sequential
    attr_reader :assets

    def initialize(*assets)
      assets.each{|label| validate_label(label)}
      @assets = assets.map{|asset| [asset, true]}.to_h
    end

    def add_asset(label)
      validate_label(label)
      @assets[label] = true
    end

    def remove_asset(label)
      validate_label(label)
      @assets.delete(label)
    end

    def sequence
      self.class.sequence
    end

    def required_assets
      sequence.select{|label, asset_spec| asset_spec.required?}
    end

    # Asset that are required to reach finish and ready to request
    def next_assets
      remaining_assets.select{|label| prereqs_ready?(label)}
    end

    # All assets that ar ready to process right now
    def requestable_assets
      sequence.keys.select{|label| prereqs_ready?(label)}
    end

    def asset_ready?(label)
      validate_label(label)
      @assets.key?(label)
    end

    def prereqs_ready?(label)
      validate_label(label)
      prereqs(label).all?{|prereq| asset_ready?(prereq)}
    end

    # Resolved prerequisites for given label
    def prereqs(label)
      validate_label(label)
      sequence[label].prereqs.map{|reqspec| resolve_prereq(reqspec)}.compact
    end

    # Prerequisites not yet ready for asset label
    def remaining_prereqs(label)
      prereqs(label).select{|prereq| !asset_ready?(prereq)}
    end

    # Minimal remaining asset labels needed to reach required assets
    def remaining_assets
      remaining = []
      queue = required_assets.keys.select{|label| !asset_ready?(label)}
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
