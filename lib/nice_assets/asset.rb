module NiceAssets
  module Asset
    extend NiceAssets::AbstractInterface

    # Return true when asset is in a state that can be requested.
    implements :requestable?
    # Return true if the asset is currently processing.
    implements :processing?
    # Return true if asset is finished processing.
    implements :finished?
    # Return true if asset is in an error state.
    implements :failed?

    # Request processing of the asset. Return quickly -- use asynchrony as needed.
    implements :request
    # Do what needs to be done. Implement with as much or as little asynchrony as you like.
    implements :process
  end
end
