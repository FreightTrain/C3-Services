module Services
  class RiakHelper

    attr_reader :client

    def initialize(ip_addresses)
      @client = create_client(ip_addresses)
    end

    def store(bucket, key)
      object = @client.bucket(bucket).new(key)
      object.content_type = 'application/json'
      object.raw_data = '{}'
      object.store
    end

    private

    def create_client(ip_addresses)
      # new client every time
      require 'riak'
      Riak.disable_list_keys_warnings = true
      riak_nodes = ip_addresses.map do |ip|
        {:host => ip,  :pb_port => 8087}
      end
      Riak::Client.new(protocol: 'pbc', nodes: riak_nodes)
    end

  end
end
