RSpec.describe PreferredPictures do
  it "has a version number" do
    expect(PreferredPictures::VERSION).not_to be nil
  end

  it "does something useful" do
    client = PreferredPictures::Client.new("testidentity", "secret123456")
    url = client.createChooseUrl(['red', 'green', 'blue'], 'test-tournament',
       600, 3600, "https://example.com/image-", ".jpg")

    expect(url).to start_with("https://")
  end
end
