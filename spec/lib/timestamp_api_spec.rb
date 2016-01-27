require "spec_helper"

describe TimestampAPI do
  it "has a version number" do
    expect(TimestampAPI::VERSION).not_to be nil
  end

  it "has the default API endpoint configured" do
    expect(TimestampAPI.api_endpoint).to eq "https://api.ontimestamp.com/api"
  end

  describe ".api_key" do
    it "sets the API key globally" do
      expect{ TimestampAPI.api_key = "MY_API_KEY" }.to change{ TimestampAPI.api_key }.from(nil).to("MY_API_KEY")
    end
  end

  describe ".request(method, url)" do
    def api_url_for(path); TimestampAPI.api_endpoint + path end

    class TimestampAPI::Fake < TimestampAPI::Model; has_attributes :name; end

    let(:response) { [].to_json }

    before do
      TimestampAPI.api_key = "MY_API_KEY"
      TimestampAPI::ModelRegistry.register(TimestampAPI::Fake)
      stub_request(:any, api_url_for("/path?param1=value1&param2=value2")).to_return(body: response)
    end

    subject { TimestampAPI.request(:get, "/path", param1: "value1", param2: "value2") }

    it "calls the API on the proper endpoint URL with proper path and proper query string parameters" do
      subject
      expect(a_request(:any, api_url_for("/path?param1=value1&param2=value2"))).to have_been_made
    end

    it "calls the API with the proper HTTP verb" do
      subject
      expect(a_request(:get, /.*/)).to have_been_made
    end

    it "calls the API with the API key in headers" do
      subject
      expect(a_request(:any, /.*/).with(headers: {"X-API-Key" => "MY_API_KEY"})).to have_been_made
    end

    it "calls the API for JSON" do
      subject
      expect(a_request(:any, /.*/).with(headers: {"Accept" => "application/json"})).to have_been_made
    end

    it "calls the API with a user agent" do
      subject
      expect(a_request(:any, /.*/).with(headers: {"User-Agent" => "TimestampAPI Ruby gem (https://github.com/alpinelab/timestamp_api)"})).to have_been_made
    end

    context "when server returns HTML instead of JSON" do
      let(:response) { "<html>Some HTML</html>" }

      it "raises a InvalidServerResponse error" do
        expect{ subject }.to raise_error(TimestampAPI::InvalidServerResponse)
      end
    end

    context "when server returns a hash" do
      let(:response) { {object: "fake", name: "fakename"}.to_json }

      it "creates a Model out of it" do
        data = subject
        expect(data).to be_a TimestampAPI::Model
        expect(data.name).to eq "fakename"
      end
    end

    context "when server returns an array" do
      let(:response) { [{object: "fake"}, {object: "fake"}].to_json }

      it "returns an array of Collection of Models" do
        data = subject
        expect(data).to be_a TimestampAPI::Collection
        expect(data).to all be_a TimestampAPI::Model
      end
    end
  end
end