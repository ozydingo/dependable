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

    def prerequisites_complete?(name, completed_nodes)
      validate_node(name)
      completed_nodes.each{|node| validate_node(node)}
      (prerequisites(name) - completed_nodes).empty?
    end

    def prerequisites(name)
      validate_node(name)
      @nodes[name][:after].dup
    end

    def next_nodes_for(output_node, completed_nodes)
      remaining_nodes_to(output_node, completed_nodes).select{|node| prerequisites_complete?(node, completed_nodes)}
    end

    def remaining_nodes_to(output_node, completed_nodes)
      completed_nodes.each{|node| validate_node(node)}
      remaining = []
      queue = [output_node]
      while label = queue.shift
        next if completed_nodes.include?(label)
        remaining << label
        queue |= prerequisites(label) - remaining
      end
      return remaining
    end
  end
end
