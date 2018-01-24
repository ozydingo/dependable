module NiceAssets
  class AssetGraph
    def initialize
      @nodes = {}
    end

    def add_node(name, after: nil)
      !node?(name) or raise "Already defined a node named #{name}"
      prerequisites = [*after]
      prerequisites.each{|node| validate_node(node)}
      @nodes[name] = {after: prerequisites}
    end

    def node?(name)
      @nodes.key?(name)
    end

    def validate_node(name)
      node?(name) or raise "No asset node named #{name} (#{name.class})"
    end

    def prerequisites(name)
      validate_node(name)
      @nodes[name][:after].dup
    end

    def prerequisites_complete?(name, completed_node_cache)
      validate_node(name)
      prerequisites(name).all?{|pre| node_complete?(pre, completed_node_cache)}
    end

    def next_nodes_for(output_node, completed_node_cache)
      remaining = remaining_nodes_to(output_node, completed_node_cache)
      return remaining.select{|node| prerequisites_complete?(node, completed_node_cache)}
    end

    def remaining_nodes_to(output_node, completed_node_cache)
      remaining = []
      queue = [output_node]
      while label = queue.shift
        next if node_complete?(label, completed_node_cache)
        remaining << label
        queue |= prerequisites(label) - remaining
      end
      return remaining
    end

    def node_complete?(name, completed_node_cache)
      case completed_node_cache
      when Array then completed_node_cache.include?(name)
      when NiceAssets::AssetWorkflow then !completed_node_cache.node_pending?(name)
      else raise TypeError, "Wrong type for completed_node_cache: must be Array or AssetWorkflow"
      end
    end
  end
end
