module NiceAssets
  class CascadePoint
    attr_reader :label, :required, :prereq

    def initialize(label, required: true, prereq: nil)
      @label = label
      @required = !!required
      @prereqs = [prereq].flatten.compact

      validate_label
      validate_prereqs
    end

    alias_method :required?, :required

    def known_prereqs
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
          req.arity == 0 or raise ArgumentError, "Invalid prerequisite: Proc must take no args."
          req.call.is_a?(Symbol) or raise ArgumentError, "Invalid prerequisite: Proc must evaluate to a Symbol"
        else
          req.is_a?(Symbol) or raise ArgumentError, "Invalid prerequisite: Must be a Symbol, Hash, or Proc."
        end
      end
    end
  end
end
