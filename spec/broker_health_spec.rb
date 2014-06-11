require_relative '../lib/broker_health'

module Services
  describe BrokerHealth do
    it 'fetches the broker catalog' do
      h = BrokerHealth.new
      expect(h).to receive(:open).with('http://127.0.0.1:8080/v2/catalog', 'X-Broker-Api-Version' => '2.1',
        :http_basic_authentication => ['admin', 'admin'], :read_timeout => 5)
      h.check_health!(['127.0.0.1'])
    end
    it 'allows the port to be overridden' do
      h = BrokerHealth.new(port: 8081)
      expect(h).to receive(:open).with('http://127.0.0.1:8081/v2/catalog', 'X-Broker-Api-Version' => '2.1',
        :http_basic_authentication => ['admin', 'admin'], :read_timeout => 5)
      h.check_health!(['127.0.0.1'])
    end
    it 'allows the credentials to be overridden' do
      h = BrokerHealth.new(username: 'foo', password: 'bar')
      expect(h).to receive(:open).with('http://127.0.0.1:8080/v2/catalog', 'X-Broker-Api-Version' => '2.1',
        :http_basic_authentication => ['foo', 'bar'], :read_timeout => 5)
      h.check_health!(['127.0.0.1'])
    end
  end
end
