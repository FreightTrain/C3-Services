require 'rake'
require 'securerandom'

module Services

  class BrokerHelper

    include Rake::DSL

    def perform_service_integration_test(t, bm)
      app_name = "#{t[:service_name]}-test-#{SecureRandom.uuid}"
      app_test_url = "http://#{app_name}.#{t[:cf_credentials][:app_domain]}"
      sh "cf api --skip-ssl-validation https://api.#{t[:cf_credentials][:app_domain]}"
      sh "cf auth #{t[:cf_credentials][:username]} #{t[:cf_credentials][:password]}"
      begin
        sh "cf create-org #{app_name}"
        sh "cf create-space #{app_name} -o #{app_name}"
        sh "cf target -o #{app_name} -s #{app_name}"
        sh "cf create-service #{t[:service_name]} #{t[:plan_name]} #{app_name}"
        local_dir = local_repo_path(t[:test_app_repo_url])
        rm_rf local_dir
        sh "git clone --depth 1 #{t[:test_app_repo_url]}"
        sh "cf push #{app_name} -p ./#{local_dir}"
        sh "cf bind-service #{app_name} #{app_name}"
        sh "cf restart #{app_name}"
        open("#{app_test_url}#{t[:test_endpoint]}", :read_timeout => 5)
        bm.recreate_job(t[:service_job], 0)
        open("#{app_test_url}#{t[:test_endpoint]}", :read_timeout => 5)
      ensure
        sh "cf delete-org -f #{app_name}"
      end
    end

    private

    def local_repo_path(git_repo_url)
      repo_path = URI.parse(git_repo_url).path
      Pathname.new(repo_path).basename.sub_ext('').to_s
    end

  end

end
