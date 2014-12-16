class HTTPTestClient
  class << self ; attr_accessor :body ; end

  Response = Struct.new(:body) do
    def code ; '200' ; end
  end

  def initialize(protocol, host)
  end

  def get(url)
    HTTPTestClient::Response.new(self.class.body)
  end
end
