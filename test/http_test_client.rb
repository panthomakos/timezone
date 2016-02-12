class HTTPTestClient
  Response = Struct.new(:body) do
    def code; '200'; end
  end

  attr_accessor :body

  # TODO: Modify once on 1.0.0
  def initialize(_protocol, _url = nil)
  end

  def get(_url)
    HTTPTestClient::Response.new(body)
  end
end
