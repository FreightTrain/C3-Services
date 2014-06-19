require 'rake'
require 'securerandom'

module Services

  class ServiceLimit

    class LimitNotEnforcedError < StandardError; end

    include Rake::DSL

    def confirm_limit_is_enforced(t, bm)
      org_name = "#{t[:service_name]}-test-#{SecureRandom.uuid}"
      sh "cf api --skip-ssl-validation https://api.#{t[:cf_credentials][:app_domain]}"
      sh "cf auth #{t[:cf_credentials][:username]} #{t[:cf_credentials][:password]}"
      begin
        sh "cf create-org #{org_name}"
        sh "cf create-space #{org_name} -o #{org_name}"
        sh "cf target -o #{org_name} -s #{org_name}"
        (0...t[:instance_count]).each do |instance_index|
          sh "cf create-service #{t[:service_name]} #{t[:plan_name]} #{t[:service_name]}-#{instance_index}"
        end
        begin
          sh "cf create-service #{t[:service_name]} #{t[:plan_name]} #{t[:service_name]}-should-fail"
          raise LimitNotEnforcedError, "Expected service instance limit of #{t[:instance_count]} to be imposed"
        rescue RuntimeError => e
          raise unless e.message =~ /cf create-service/
        end
      ensure
        sh "cf delete-org -f #{org_name}"
      end
    end

  end

end
