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
      yield if block_given?
      confirm_persisted_data_is_still_present(ip_addresses)
    end

    private

    def persist_data(ip_addresses)
      r = RiakHelper.new(ip_addresses)
      # add service instance reference so that our bucket will not be removed by the broker
      r.store(BROKER_BUCKET, TEST_BUCKET)
      # actually persist the data
      r.store(TEST_BUCKET, TEST_KEY)
    end

    def confirm_persisted_data_is_still_present(ip_addresses)
      client = RiakHelper.new(ip_addresses).client
      raise unless client[TEST_BUCKET][TEST_KEY].raw_data == '{}'
    end
  end
end
