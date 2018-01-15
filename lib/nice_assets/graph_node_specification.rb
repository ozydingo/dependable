module NiceAssets
  class GraphNodeSpecification
    attr_reader :label, :required, :prereqs, :read_only

    class << self
      def output(label, prereq: [])
        new(label, required: true, prereq: prereq)
      end

      def link(label, prereq: [])
        new(label, required: false, prereq: prereq)
      end

      def reference(label)
        new(label, required: false, read_only: true)
      end
    end

    def initialize(label, required: true, prereq: nil, read_only: false)
      @label = label
      @required = !!required
      @prereqs = [prereq].flatten.compact
      @read_only = read_only

      validate_label
      validate_prereqs
    end

    alias_method :required?, :required
    alias_method :read_only?, :read_only

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
      raise ArgumentError, "Read-only asset cannot have prerequisites" if read_only? && !@prereqs.empty?
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
  end
end
