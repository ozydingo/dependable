# TODO --
# finishable?
# finished?
# upstream_from(label)
# downstream_from(label)
# resume
# request asset
# handle finished asset

module NiceAssets
  class Workflow
    extend Fluid
    attr_reader :assets

    def initialize(assets = {})
      assets.each do |label, asset|
        validate_label(label)
        validate_asset(label, asset)
      end
      @assets = assets
    end

    def asset_specs
      self.class.asset_specs
    end

    def required_assets
      # TODO: exclude skip-assets
      asset_specs.select{|label, asset_spec| asset_spec.required?}
    end

    def asset_ready?(label)
      validate_label(label)
      !!@assets[label]
    end

    # Resolved prerequisites for given label
    def prereqs(label)
      validate_label(label)
      asset_specs[label].prereqs.map{|reqspec| resolve_prereq(reqspec)}.compact
    end

    # Prerequisites not yet ready for asset label
    def remaining_prereqs(label)
      prereqs(label).select{|prereq| !asset_ready?(prereq)}
    end

    # Minimal remaining asset labels needed to reach required assets
    def remaining_assets
      remaining = []
      queue = required_assets.keys.select{|label| !asset_ready?(label)}
      while label = queue.shift
        remaining << label
        queue |= remaining_prereqs(label) - remaining
      end
      return remaining
    end

    # Asset labels that are required to reach finish and ready to request
    def next_assets
      remaining_assets.select{|label| prereqs_ready?(label)}
    end

    # All asset labels that are ready to be requested
    def requestable_assets
      asset_specs.select{|label| prereqs_ready?(label)}
    end

    def prereqs_ready?(label)
      validate_label(label)
      prereqs(label).all?{|prereq| asset_ready?(prereq)}
    end

    private

    def validate_label(label)
      label.is_a?(Symbol) or raise ArgumentError, "Label must be a Symbol"
      asset_specs.key?(label) or raise ArgumentError, "Unrecognized asset label: #{label}"
    end

    def validate_asset(label, asset)
      validate_label(label)
      if !asset.nil?
        if asset_specs[label].read_only?
          valid_reference?(asset) or raise ArgumentError, "Reference must either be boolean or respond to `finished?`"
        else
          valid_processable?(asset) or raise ArgumentError, "Processable Asset must be a NiceAssets::Asset"
        end
      end
    end

    def valid_processable?(asset)
      asset.is_a?(NiceAssets::Asset)
    end

    def valid_reference?(asset)
      asset == true || asset = false || asset.respond_to?(:finished?)
    end

    def resolve_prereq(reqspec)
      case reqspec
      when Symbol then reqspec
      when Proc then send(reqspec.call)
      when Hash then evaluate_conditional_prereq(reqspec)
      else raise "Invalid asset requirement for #{self}: #{reqspec}. Must be a Symbol, Proc, or Hash!"
      end
    end

    def evaluate_conditional_prereq(reqspec)
      match = req.keys.find{|condition| condition == "else" || public_send(condition)}
      return match && req[match]
    end

  end
end
