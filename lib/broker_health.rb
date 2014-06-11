require 'open-uri'

module Services
  class BrokerHealth

    def initialize(options={})
      @options = {port: 8080, username: 'admin', password: 'admin'}.merge!(options)
    end

    def check_health!(ip_addresses)
      timeout 5 do
        open(broker_url(ip_addresses),
          'X-Broker-Api-Version' => '2.1',
          :http_basic_authentication => [@options[:username], @options[:password]],
          :read_timeout => 5
        )
      end
    end

    private

    def broker_url(ip_addresses)
      "http://#{ip_addresses.first}:#{@options[:port]}/v2/catalog"
    end

  end
end
