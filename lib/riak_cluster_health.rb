require "net/https"
require "uri"
require 'json'


module Services
  class RiakClusterHealth

    def check_health!(ip_addresses)

      for connect_server in ip_addresses.each do
        uri = URI.parse("https://#{connect_server}:8096/admin/cluster")
        http = Net::HTTP.new(uri.host, uri.port )
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.open_timeout = 5
        http.read_timeout = 5

        request = Net::HTTP::Get.new(uri.request_uri)
        request.basic_auth("user", "pass")

        response = http.request(request)
        raise "cant connect to node #{connect_server}" unless response.code.to_i == 200

        riak_status = JSON.parse(response.body)['cluster']['current']
        for check_for_server in ip_addresses.each do
          server_ring_state = riak_status.select { |s| s['name'] == "riak@#{check_for_server}" }
          raise "Didn't find server #{check_for_server} in ring membership of server #{connect_server}" if server_ring_state.empty?
          raise "Server #{check_for_server} is not healthy according to #{connect_server}" unless server_ring_state.first['status'] == 'valid' && server_ring_state.first['reachable'] == true
        end
      end

    end
  end
end
