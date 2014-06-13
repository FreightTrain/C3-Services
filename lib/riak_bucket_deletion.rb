require 'i18n'

module Services
  class RiakBucketDeletion

    I18n.enforce_available_locales = false

    BUCKET_NAME = 'to_be_deleted'

    def check_health!(ip_addresses)

      r = RiakHelper.new(ip_addresses)
      r.store(BUCKET_NAME, 'foobar')

      sleep 70

      if r.client.buckets.map{|b| b.name}.include?(BUCKET_NAME)
        raise 'Failed to delete bucket marked for deletion'
      end
    end

  end
end
