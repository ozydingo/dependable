module NiceAssets
  class AssetGraph
    def initialize
      @nodes = {}
    end

    def add_node(name, after: nil)
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

    def ready_to_process?(name, completed_nodes)
      validate_node(name)
      completed_nodes.each{|node| validate_node(node)}
      (prerequisites(name) - completed_nodes).empty?
    end

    def prerequisites(name)
      validate_node(name)
      @nodes[name][:after].dup
    end

    def next_nodes_for(output_node, completed_nodes)
      remaining_nodes_to(output_node, completed_nodes).select{|node| ready_to_process?(node, completed_nodes)}
    end

    def ready_to_process(completed_nodes)
      @node.keys.select{|name| ready_to_process?(name, completed_nodes)}
    end

    def remaining_nodes_to(output_node, completed_nodes)
      return [] if completed_nodes.include?(output_node)
      remaining = []
      queue = [output_node]
      while label = queue.shift
        remaining << label
        queue |= incomplete_prerequisites(label, completed_nodes) - remaining
      end
      return remaining
    end

    def incomplete_prerequisites(node, completed_nodes)
      validate_node(node)
      completed_nodes.each{|node| validate_node(node)}
      prerequisites(node) - completed_nodes
    end
  end
end
