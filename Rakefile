require 'rspec/core/rake_task'
require 'yaml'

require_relative 'lib/services'
require_relative 'bosh-mediator/lib/bosh_mediator_factory'

include ::BoshMediator::BoshMediatorFactory
include ::Services::RakeHelper

RSpec::Core::RakeTask.new(:spec)
task :default => :spec

%w(rmq riak).each do |service|

  namespace service.to_sym do
    desc 'Create the release'
    task :create_release do
      bosh_mediator = create_local_bosh_mediator(release_dir(service))
      bosh_mediator.create_release(service)
    end

    desc 'Upload and deploy the release to the BOSH director'
    bosh_task :upload_and_deploy_release, service do |b, rd|
      b.upload_dev_release(rd)
      b.deploy
    end

    desc 'Recreate server 0'
    bosh_task :recreate_server, service do |b|
      b.recreate_job(service, 0)
    end

    desc 'Register the service broker with Cloud Foundry'
    bosh_task :register_service_broker, service do |b|
      b.run_errand "#{service}_broker_registrar"
    end

    desc 'Delete the specified deployment'
    task :delete_deployment, [:director_url, :spiff_dir, :username, :password] do |_, args|
      deployment_name = YAML.load_file(File.join(args[:spiff_dir], 'env.yml'))['name']
      with_bosh_mediator(service, args) do |bm, release_dir|
        bm.delete_deployment(deployment_name)
      end
    end
  end

end

namespace :rmq do |nm|

  desc 'Test the specified deployment'
  task :test_deployment, [:spiff_dir] do |_, args|
    ip = Services::Addresses.new(args[:spiff_dir])
    Services::BrokerHealth.new(port: 9998).check_health!(ip.addresses_for_job('rmq_broker'))
  end

  desc 'Cloud Foundry integration test'
  integration_task :integration_test, 'rmq' do |test_args, bm|
    Services::BrokerHelper.new.perform_service_integration_test(test_args.merge(
      service_name: 'rabbitmq',
      plan_name: 'default',
      test_app_repo_url: 'https://github.com/FreightTrain/labrat.git',
      test_endpoint: '/services/rabbitmq'
    ), bm)
  end

end

namespace :riak do |nm|

  desc 'Test the specified deployment'
  bosh_task :test_deployment, 'riak' do |bm, _, args|
    ip = Services::Addresses.new(args[:spiff_dir])
    Services::RiakHealth.new.check_health!(ip.addresses_for_job('riak'))
    Services::RiakBucketDeletion.new.check_health!(ip.addresses_for_job('riak'))
    Services::RiakPersistence.new(bm).check_health!(ip.addresses_for_job('riak'))
    Services::BrokerHealth.new(port: 9292).check_health!(ip.addresses_for_job('riak_broker'))
  end

  desc 'Cloud Foundry integration test'
  integration_task :integration_test, 'riak' do |test_args, bm|
    %w(bitcask leveldb).each do |plan|
      Services::BrokerHelper.new.perform_service_integration_test(test_args.merge(
        service_name: 'riak',
        plan_name: plan,
        test_app_repo_url: 'https://github.com/FreightTrain/riak-hello-world.git',
        test_endpoint: '/'
      ), bm)
    end
  end

end

namespace :cf do

  desc 'Upload and deploy the release to the BOSH director'
  task :upload_and_deploy_release, [:release_file, :manifest_file, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = Dir.pwd
    release_file = Services::BoshHelper.new.local_release_file(args[:release_file], release_dir)

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    stemcell_release_info = bosh_mediator.upload_stemcell_to_director(args[:stemcell_resource_uri])
    stemcell_release_info.merge!(:release_version => YAML.load_file(release_file)['version'])
    manifest_file = BoshMediator::ManifestWriter.new(args[:manifest_file], stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.upload_release(release_file)
    bosh_mediator.deploy
  end

  desc 'Delete the specified CF deployment'
  task :delete_deployment, [:director_url, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)
    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], Dir.pwd)
    deployment_name = YAML.load_file(File.join(args[:spiff_dir], 'env.yml'))['meta']['name']
    bosh_mediator.delete_deployment(deployment_name)
  end

end
