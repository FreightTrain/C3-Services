module Services
  class RiakBucketDeletion

    I18n.enforce_available_locales = false

    def check_health!(ip_addresses)
      require 'riak'
      Riak.disable_list_keys_warnings = true
      riak_nodes = ip_addresses.map do |ip|
        {:host => ip,  :pb_port => 8087}
      end
      client = Riak::Client.new(:protocol => 'pbc', :nodes => riak_nodes)
      object = client.bucket('to_be_deleted').new('foobar')
      object.content_type = 'foo'
      object.raw_data = 'baz'
      object.store

      sleep 70

      if client.buckets.map{|b| b.name}.include?('to_be_deleted')
        raise 'Failed to delete bucket marked for deletion'
      end
    end

  end
end
