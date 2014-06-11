require_relative '../lib/addresses'

module Services
  describe Addresses do
    it 'loads the environment yaml relative to the spiff directory' do
      a = Addresses.new('/foo/bar')
      expect(YAML).to receive(:load_file).with('/foo/bar/env.yml').and_return({'jobs' => []})
      a.addresses_for_job('foo')
    end
    it 'returns the static ips associated with a job' do
      a = Addresses.new('/foo/bar')
      allow(YAML).to receive(:load_file).with('/foo/bar/env.yml').and_return({
        'jobs' => [
          {
            'name' => 'foo',
            'networks' => [{
              'static_ips' => ['127.0.0.1', '255.255.255.0']
            }]
          },
          {
            'name' => 'bar',
            'networks' => [{
              'static_ips' => ['8.8.8.8', '1.1.1.1']
            }]
          }]
      })
      expect(a.addresses_for_job('foo')).to eq(['127.0.0.1', '255.255.255.0'])
    end
  end
end
