module NiceAssets
  module AssetWorkflowClassMethods
    attr_reader :asset_roster, :asset_graph, :output_assets, :owner_class

    def inherited(child)
      child.instance_eval do
        @asset_roster = NiceAssets::AssetRoster.new
        @asset_graph = NiceAssets::AssetGraph.new
        @output_assets = []
      end
    end

    def owned_by(klass)
      !defined?(@owned_by) or raise "Note for resale: #{self} already has an owner."
      @owner_class = klass
    end

    def asset(name, scope = nil,
        after: nil,
        as: "asset",
        class_name: nil,
        foreign_key: nil,
        &callback_block)
      defined?(@owner_class) or raise "No owner class defined for #{self}. Please use `owned_by(klass)` first."

      assoc = SelfishAssociations::Associations::HasOne.new(name, @owner_class, scope,
        foreign_key: foreign_key,
        class_name: class_name)
      spec = NiceAssets::AssetSpecification.new(assoc)
      @asset_roster.add_spec(name, spec)
      @asset_graph.add_node(name, after: after)
      @output_assets << name
      return name
    end

    def outputs(*assets)
      @output_assets = assets
    end
  end
end
