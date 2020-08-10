require 'httparty'

RSpec.describe PreferredPictures do
  it "has a version number" do
    expect(PreferredPictures::VERSION).not_to be nil
  end

  it "creates a basic client url" do
    client = PreferredPictures::Client.new(identity: "testidentity", secret_key: "secret123456")
    url = client.createChooseUrl(choices: ['red', 'green', 'blue'],
      tournament: 'test-tournament',
      choices_prefix: "https://example.com/image-",
      choices_suffix: ".jpg")

    expect(url).to start_with("https://api.preferred-pictures.com/choose")
  end

  it "errors on no options" do
    client = PreferredPictures::Client.new(identity: "testidentity", secret_key: "secret123456")
    expect {
      url = client.createChooseUrl(
        choices: [],
        tournament: 'test-tournament',
        choices_prefix: "https://example.com/image-",
        choices_suffix: ".jpg"
      )
    }.to raise_error(/No choices were supplied/)
  end

  it "calculates a correct signature and returns a redirect" do
    identity = ENV["PP_IDENTITY"]
    secret_key = ENV["PP_SECRET_KEY"]

    if identity == nil || secret_key == nil
      skip "No identity or secret_key set in environment"
    end

    client = PreferredPictures::Client.new(identity: identity, secret_key: secret_key)

    url = client.createChooseUrl(
      choices: ['a', 'b', 'c'],
      tournament: 'test-ruby-tournment',
      choices_prefix: "https://example.com/image-",
      choices_suffix: ".jpg"
    )

    response = HTTParty.get(url, follow_redirects: false)

    expect(response.code).to equal(302)
    expect(response.headers['location']).to start_with("https://example.com/image-")
  end
end
