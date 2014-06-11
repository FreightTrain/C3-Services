require 'riak'

module Services
  class RiakHealth
    def check_health!(ip_addresses)
      timeout 5 do
        payload = '<html><body>Hello, world!</body></html>'

        riak_nodes = ip_addresses.map{|ip| {host: ip,  pb_port: 8087} }
        client = Riak::Client.new(nodes: riak_nodes, protocol: 'pbc')
        bucket = client.bucket('doc')
        object = bucket.get_or_new('index.html')
        object.raw_data = payload
        object.content_type = 'text/html'
        object.store

        object.reload :force => true

        raise unless client['doc']['index.html'].raw_data == payload
      end
    end
  end
end
