# TODO:
     # asset roles


module NiceAssets
  module Fluid
    def inherited(child)
      child.initialize_flow
      super
    end

    def asset_specs
      base? ? {} : superclass.asset_specs.merge(@asset_specs)
    end

    def workflow_callbacks(event, position)
      callbacks = @workflow_callbacks.dig(event, position)
      callbacks ||= superclass.workflow_callbacks(event, position) unless base?
      return callbacks
    end

    def asset_callbacks(label, event, position)
      callbacks = @asset_callbacks.dig(label, event, position)
      callbacks ||= superclass.asset_callbacks(label, event, position) unless base?
      return callbacks
    end

    def output(label, after: [])
      node_spec = ::NiceAssets::GraphNodeSpecification.new(label, required: true, prereq: after)
      add_asset(label, node_spec)
    end

    def link(label, after: [])
      node_spec = ::NiceAssets::GraphNodeSpecification.new(label, required: false, prereq: after)
      add_asset(label, node_spec)
    end

    def reference(label)
      node_spec = ::NiceAssets::GraphNodeSpecification.new(label, required: false, read_only: true)
      add_asset(label, node_spec)
    end

    def before_resume(*callbacks)
      add_workflow_callbacks(:resume, :before, *callbacks)
    end

    def after_resume(*callbacks)
      add_workflow_callbacks(:resume, :after, *callbacks)
    end

    def before_request(label, *callbacks)
      add_asset_callback(label, :request, :before, *callbacks)
    end

    def after_request(label, *callbacks)
      add_asset_callback(label, :request, :after, *callbacks)
    end

    def before_finish(label, *callbacks)
      add_asset_callback(label, :finish, :before, *callbacks)
    end

    def after_finish(label, *callback)
      add_asset_callback(label, :finish, :after, *callbacks)
    end

    def add_workflow_callbacks(event, positions, *callbacks)
      callbacks.each do |callback|
        validate_callback(callback)
        @workflow_callbacks[event] ||= {}
        @workflow_callbacks[event][position] = callback
      end
    end

    def add_asset_callback(label, event, position, *callbacks)
      callbacks.each do |callback|
        validate_callback(callback)
        @asset_callbacks[label] ||= {}
        @asset_callbacks[label][event] ||= {}
        @asset_callbacks[label][event][position] = callback
      end
    end

    protected

    def base?
      self == ::NiceAssets::Workflow
    end

    def initialize_flow
      @asset_specs = {}
      @asset_callbacks = {}
      @workflow_callbacks = {}
    end

    def validate_callback(callback)
      callback.is_a?(Symbol) || callback.is_a?(Proc) or raise ArgumentError, "Callback must be a Symbol or a Proc"
    end

    def add_asset(label, spec)
      (spec.known_prereqs - asset_specs.keys).each{|label| raise ArgumentError, "Unrecognized asset prerequisite: \"#{label}\""}
      @asset_specs[spec.label] = spec
    end
  end
end
