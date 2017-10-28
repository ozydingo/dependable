# TODO:
# - workflow_callbacks (all)
# - asset_callbacks (all)

module NiceAssets
  module Fluid
    def inherited(child)
      child.initialize_flow
      super
    end

    def asset_specs
      base? ? {} : superclass.asset_specs.merge(@asset_specs)
    end

    def workflow_callback(event, position)
      callbacks = @workflow_callbacks.dig(event, position)
      callbacks ||= superclass.workflow_callbacks(event, position) unless base?
      return callbacks
    end

    def asset_callback(label, event, position)
      callbacks = @workflow_callbacks.dig(label, event, position)
      callbacks ||= superclass.asset_callbacks(label, event, position) unless base?
      return callbacks
    end

    def process(label, required: true, after: [], wait_until: nil, include_if: nil)
      asset_spec = ::NiceAssets::AssetSpecification.new(label, required: required, prereq: after, wait_until: wait_until, include_if: include_if)
      (asset_spec.known_prereq_labels - asset_specs.keys).each{|label| raise ArgumentError, "Unrecognized asset prerequisite: \"#{label}\""}
      @asset_specs[asset_spec.label] = asset_spec
    end

    def before_start(*callbacks)
      add_workflow_callback(:start, :before, callback)
    end

    def after_start(*callbacks)
      add_workflow_callback(:start, :after, callback)
    end

    def before_request(label, *callbacks)
      add_asset_callback(label, :request, :before)
    end

    def after_request(label, *callbacks)
      add_asset_callback(label, :request, :after)
    end

    def before_resume(*callbacks)
      add_workflow_callback(:resume, :before, callback)
    end

    def after_resume(*callbacks)
      add_workflow_callback(:resume, :after, callback)
    end

    def before_finish(label, callback = nil)
      callback, label = label, nil if callback.nil?
      if label.nil?
        add_workflow_callback(:finish, :before)
      else
        add_asset_callback(label, :finish, :before)
      end
    end

    def after_finish(label, callback = nil)
      callback, label = label, nil if callback.nil?
      if label.nil?
        add_workflow_callback(:finish, :after)
      else
        add_asset_callback(label, :finish, :after)
      end
    end

    def add_workflow_callback(callback, event, positions)
      [*callback].each do
      validate_callback(callback)
      @workflow_callbacks[event] ||= {}
      @workflow_callbacks[event][position] = callback
    end

    def add_asset_callback(asset, event, position)
      validate_callback(callback)
      @workflow_callbacks[asset] ||= {}
      @workflow_callbacks[asset][event] ||= {}
      @workflow_callbacks[asset][event][position] = callback
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
  end
end
