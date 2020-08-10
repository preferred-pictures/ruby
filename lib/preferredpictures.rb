require "preferredpictures/version"
require 'securerandom'
require 'openssl'

##
# The encompassing class for the PreferredPictures API
#
module PreferredPictures

  ##
  # A class representing an error from a PreferredPictures
  # call
  class Error < StandardError; end

  ##
  # The client class of PreferredPictures
  class Client

    ##
    # Initialize a new PreferredPictures client which will be used to create
    # and sign API requests
    #
    # ==== Options
    #
    # * +:identity+ - (String) The PreferredPictures identity that will be used.
    # * +:secret_key+ - (String) The secret key associated with the identity that is used to sign requests
    # * +:max_choices+ - (Number) The maximum number of choices to allow
    # * +:endpoint+ - (String) The PreferredPictures API endpoint to use for requests.
    #
    # ==== Examples
    #
    # This will create an example PreferredPictures client.
    #
    #    client = PreferredPictures::Client.new(identity: "testidentity",
    #                                           secret_key: "secret123456")
    #
    def initialize(identity:, secret_key:, max_choices: 35, endpoint: "https://api.preferred-pictures.com/")
      @identity = identity
      @secret_key = secret_key
      @max_choices = max_choices
      @endpoint = endpoint
    end

    ##
    # Create a URL that calls the PreferredPictures API to
    # choose one option among the supplied chocies.
    #
    # ==== Options
    #
    # * +:choices+ (Array<String>) A list of choices of which the API should choose
    # * +:tournament+ (String) The tournament where this request will participate
    # * +:ttl+ (Number) The time to live for an action to be taken from the choice, specified in seconds
    # * +:expiration_ttl+ (Number) The time to live for the URL's signature, after this time the request
    # *                 will no longer be valid.
    # * +:uid+ (String) An optional unique identifier that will be used to correlate choices and
    # *      actions
    # * +:choices_prefix+ (String) An optional prefix to prepend to all of the choices.
    # * +:choices_suffix+ (String) An optional suffix to append to all of the choices.
    # * +:destinations+ (Array<String) An array of destination URLs that are paired with each of the choices
    # * +:destinations_prefix+ (String) An optional prefix to prepend to all of the destination URLs
    # * +:destinations_suffix+ (String) An optional suffix to append to all of the destination URLs
    # * +:go+ (Boolean) Indicate that the result should be a redirect to a destination URL from
    # *     a previously made choice
    # * +:json+ (Boolean) Return the choice using JSON rather than a HTTP 302 redirect.
    #
    # ==== Examples
    #
    # This will create an PreferredPictures URL that will result in a choice:
    #
    #    client = PreferredPictures::Client.new(
    #        identity: "testidentity",
    #        secret_key: "secret123456")
    #
    #    url = client.createChooseUrl(
    #        choices: ['a', 'b', 'c'],
    #        tournament: 'test-ruby-tournment',
    #        choices_prefix: "https://example.com/image-",
    #        choices_suffix: ".jpg")
    #
    #
    def createChooseUrl(choices:,
                        tournament:,
                        ttl: 600,
                        expiration_ttl: 3600,
                        uid: "",
                        choices_prefix: "",
                        choices_suffix: "",
                        destinations: [],
                        destinations_prefix: "",
                        destinations_suffix: "",
                        go: false,
                        json: false)

      if choices.length() > @max_choices
        raise Error.new "Too many choices were supplied"
      end

      if choices.length() === 0
        raise Error.new "No choices were supplied"
      end

      params = {
        "choices[]" => choices,
        # Set the expiration of the request to be an hour
        # from when it is generated.
        "expiration" => Time.now.to_i + expiration_ttl,
        # The identifier of the tournament
        "tournament" => tournament,
        "ttl" => ttl,
      };

      if uid == ""
        params['uid'] = SecureRandom.uuid
      else
        params['uid'] = uid
      end

      if choices_prefix != ""
        params['choices_prefix'] = choices_prefix
      end

      if choices_suffix != ""
        params['choices_suffix'] = choices_suffix
      end

      if destinations_prefix != ""
        params['destinations_prefix'] = destinations_prefix
      end

      if destinations_suffix != ""
        params['destinations_suffix'] = destinations_suffix
      end

      if destinations.length > 0
        params['destinations[]'] = destinations
      end

      if go
        params['go'] = 'true'
      end

      if json
        params['json'] = 'true'
      end

      signing_field_order = [
        "choices_prefix",
        "choices_suffix",
        "choices[]",
        "destinations_prefix",
        "destinations_suffix",
        "destinations[]",
        "expiration",
        "go",
        "json",
        "tournament",
        "ttl",
        "uid",
      ];

      signing_string = signing_field_order
        .select { |field_name| params.has_key?(field_name) }
        .map{ |field_name| params[field_name].kind_of?(Array) ? params[field_name].join(",") : params[field_name] }
        .join("/")

      sha256 = OpenSSL::Digest.new('sha256')
      signature = OpenSSL::HMAC.hexdigest(sha256, @secret_key, signing_string)

      params['signature'] = signature
      params['identity'] = @identity

      return @endpoint + "choose?" + URI.encode_www_form(params)
    end
  end
end
