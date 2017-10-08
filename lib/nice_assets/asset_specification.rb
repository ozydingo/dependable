module NiceAssets
  class AssetSpecification
    attr_reader :label, :required, :prereqs, :wait_until, :skip_if

    def initialize(label, required: true, prereq: nil, wait_until: nil, skip_if: nil)
      @label = label
      @required = !!required
      @prereqs = [prereq].flatten.compact
      @wait_until = [wait_until].flatten.compact
      @skip_if = [skip_if].flatten.compact

      validate_label
      validate_prereqs
      validate_wait_until
      validate_skip_if
    end

    alias_method :required?, :required

    def known_prereq_labels
      @prereqs.reject{|req| req.is_a?(Proc)}.flat_map do |req|
        case req
        when Hash then req.values
        when Symbol then req
        end
      end
    end

    private

    def validate_label
      @label.is_a?(Symbol) or raise ArgumentError, "Label must be a symbol"
    end

    def validate_prereqs
      @prereqs.each do |req|
        case req
        when Hash
          (req.keys + req.values).all?{|x| x.is_a?(Symbol)} or raise ArgumentError, "Invalid asset prerequisite: Hash must have symbol keys and values."
        when Proc
          req.arity == 0 or raise ArgumentError, "Invalid asset prerequisite: Proc must take no args."
          req.call.is_a?(Symbol) or raise ArgumentError, "Invalid asset prerequisite: Proc must evaluate to a Symbol"
        else
          req.is_a?(Symbol) or raise ArgumentError, "Invalid asset prerequisite: Must be a Symbol, Hash, or Proc."
        end
      end
    end

    def validate_wait_until
      @wait_until.each do |condition|
        condition.is_a?(Proc) || condition.is_a?(Symbol) or raise ArgumentError, "Invalid wait_until: Must be a Symbol or Proc"
      end
    end

    def validate_skip_if
      @skip_if.each do |condition|
        condition.is_a?(Proc) || condition.is_a?(Symbol) or raise ArgumentError, "Invalid skip_if: Must be a Symbol or Proc"
      end
    end
  end
end
