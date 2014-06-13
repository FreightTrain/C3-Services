module Services
  class RiakPersistence

    I18n.enforce_available_locales = false

    BROKER_BUCKET = 'service_instances'
    TEST_BUCKET = 'persistence_test'
    TEST_KEY = 'test'

    def initialize(bosh_mediator)
      @bosh = bosh_mediator
    end

    def check_health!(ip_addresses)
      persist_data(ip_addresses)
      stop_all_the_riak_nodes(ip_addresses.size)
      recreate_all_the_riak_nodes(ip_addresses.size)
      confirm_persisted_data_is_still_present(ip_addresses)
    end

    private

    def riak_client(ip_addresses)
      # new client every time
      require 'riak'
      Riak.disable_list_keys_warnings = true
      riak_nodes = ip_addresses.map do |ip|
        {:host => ip,  :pb_port => 8087}
      end
      client = Riak::Client.new(:protocol => 'pbc', :nodes => riak_nodes)
    end

    def persist_data(ip_addresses)
      client = riak_client(ip_addresses)
      # add service instance reference so that our bucket will not be removed by the broker
      write_key_to_bucket(client, BROKER_BUCKET, TEST_BUCKET)
      # actually persist the data
      write_key_to_bucket(client, TEST_BUCKET, TEST_KEY)
    end

    def write_key_to_bucket(client, bucket, key)
      object = client.bucket(bucket).new(key)
      object.content_type = 'application/json'
      object.raw_data = '{}'
      object.store
    end

    def stop_all_the_riak_nodes(node_count)
      (0...node_count).each do |job_index|
        @bosh.stop_job('riak', job_index, hard: true)
      end
    end

    def recreate_all_the_riak_nodes(node_count)
      (0...node_count).each do |job_index|
        @bosh.recreate_job('riak', job_index)
      end
    end

    def confirm_persisted_data_is_still_present(ip_addresses)
      client = riak_client(ip_addresses)
      raise unless client[TEST_BUCKET][TEST_KEY].raw_data == '{}'
    end
  end
end
