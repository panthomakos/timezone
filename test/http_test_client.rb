class HTTPTestClient
  Response = Struct.new(:body) do
    def code ; '200' ; end
  end

  attr_accessor :body

  def initialize(protocol, host)
  end

  def get(_url)
    HTTPTestClient::Response.new(body)
  end
end
