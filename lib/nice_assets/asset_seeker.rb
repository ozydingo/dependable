module NiceAssets
  class AssetSeeker
    attr_reader :owner

    def initialize(resource_class, label, scope = nil,
        owner: nil,
        class_name: nil,
        foreign_key: nil
        )
      @resource_class = resource_class
      @label = label
      @assoc_options = {
        class_name: class_name,
        foreign_key: foreign_key
      }
      @scope = scope
      @owner = owner

      #cannot be determined until all classes have been loaded
      @assoc = nil
    end

    def find_instance(resource)
      assoc.find(resource)
    end

    def initialize_instance(resource)
      assoc.initialize_for(resource)
    end

    def create_instance(resource)
      assoc.create_for(resource)
    end

    def matches_asset?(resource, asset)
      return false if !asset.is_a?(foreign_klass)
      matching_attributes(resource).all?{|field, value| asset.public_send(field) == value}
    end

    def matching_attributes(resource)
      # TODO: don't hack into the private methods
      assoc.send(:instance_find_conditions, resource)
    end

    private

    def assoc
      # @assoc ||= ar_assoc || selfish_assoc
      @asspc ||= selfish_assoc
    end

    def ar_assoc
      @resource_class.reflect_on_association(@label)
    end

    def selfish_assoc
      SelfishAssociations::Associations::HasOne.new(@label, @resource_class, @scope, **@assoc_options)
    end

    def foreign_klass
      assoc.foreign_class
    end
  end
end
