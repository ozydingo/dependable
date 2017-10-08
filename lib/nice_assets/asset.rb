module NiceAssets
  module Asset
    extend NiceAssets::AbstractInterface

    # Return true when ready to be requested
    implements :requestable?
    # Request processing of the asset. Expected to return quickly -- use asynchrony as needed.
    implements :request
    # Do what needs to be done. Implement with as much or as little asynchrony as you like.
    implements :process
    # Return true if the asset is currently processing.
    implements :processing?
    # Return true if asset is finished processing
    implements :ready?
    # Return true if asset is in an error state
    implements :failed?

  end
end
