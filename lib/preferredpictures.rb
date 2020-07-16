require "preferredpictures/version"
require 'securerandom'
require 'openssl'

module PreferredPictures
  class Error < StandardError; end

  class Client

    # Initialize a new Preferred.pictures client which will be used to create
    # and sign API requests
    #
    # - identity: The Preferred.pictures identity that will be used.
    # - secret_key: The secret key associated with the identity that is used to sign requests
    # - max_choices: The maximum number of choices to allow
    # - endpoint: The Preferred.pictures API endpoint to use.
    #
    def initialize(identity, secret_key, max_choices=35, endpoint="https://api.preferred.pictures/")
      @identity = identity
      @secret_key = secret_key
      @max_choices = max_choices
      @endpoint = endpoint
    end

    # Return a URL that calls the Preferred.pictures API to choose one option
    # among the supplied chocies.
    #
    # - choices: A list of choices of which the API should choose
    # - tournament: The tournament where this request will participate
    # - ttl: The time to live for an action to be taken from the choice, specified in seconds
    # - expiration_ttl: The time to live for the URL's signature, after this time the request
    #                   will no longer be valid.
    # - prefix: An optional prefix to prepend to all of the choices.
    # - suffix: An optional suffix to append to all of the choices.
    #
    def createChooseUrl(choices, tournament, ttl=600, expiration_ttl=3600, prefix="", suffix="")

      if choices.length() > @max_choices
        raise Error.new "Too many choices were supplied"
      end

      params = {
        "choices" => choices.join(","),
        # Set the expiration of the request to be an hour
        # from when it is generated.
        "expiration" => Time.now.to_i + expiration_ttl,
        # The identifier of the tournamen
        "tournament" => tournament,
        # The unique id of this request
        "uid" => SecureRandom.uuid,
        "ttl" => ttl,
      };

      if prefix != ""
        params['prefix'] = prefix
      end

      if suffix != ""
        params['suffix'] = suffix
      end

      signing_field_order = [
        "choices",
        "expiration",
        "prefix",
        "suffix",
        "tournament",
        "ttl",
        "uid",
      ];

      signing_string = signing_field_order
        .select { |field_name| params.has_key?(field_name) }
        .map{|field_name| params[field_name]}
        .join("/")


      sha256 = OpenSSL::Digest.new('sha256')
      signature = OpenSSL::HMAC.hexdigest(sha256, @secret_key, signing_string)

      return @endpoint + "choose-uri?" + URI.encode_www_form(params)
    end

  end
end
