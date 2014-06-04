require_relative 'bosh-mediator/lib/bosh_mediator_factory'
require_relative 'bosh-mediator/lib/manifest_writer'
require_relative 'bosh-mediator/lib/release_manager'
require 'yaml'
require 'open-uri'

include ::BoshMediator::BoshMediatorFactory
include ::BoshMediator::DownloadHelper

namespace :rmq do

  desc 'Create the RMQ release'
  task :create_release do
    release_dir = File.dirname(__FILE__) + '/rmq'
    bosh_mediator = create_local_bosh_mediator(release_dir)
    bosh_mediator.create_release('rmq')
  end

  desc 'Upload and deploy the release to the BOSH director'
  task :upload_and_deploy_release, [ :core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/rmq'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    
    release_manifest = BoshMediator::ReleaseManager.new.find_dev_release(release_dir)
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => YAML.load_file(release_manifest)['version'])
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.upload_dev_release(release_dir)
    bosh_mediator.deploy
  end

  desc 'Recreate RMQ server 0'
  task :recreate_rmq_server, [ :core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/rmq'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => 'latest')
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.recreate_job('rmq',0)
  end


  desc 'Register the RMQ service broker with Cloud Foundry'
  task :register_service_broker, [:core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/rmq'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)

    release_manifest = BoshMediator::ReleaseManager.new.find_dev_release(release_dir)
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => YAML.load_file(release_manifest)['version'])
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.run_errand 'rmq_broker_registrar'
  end

  desc 'Delete the specified RMQ deployment'
  task :delete_deployment, [:director_url, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)
    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], Dir.pwd)
    deployment_name = YAML.load_file(File.join(args[:spiff_dir], 'env.yml'))['name']
    bosh_mediator.delete_deployment(deployment_name)
  end

  desc 'Test the specified deployment'
  task :test_deployment, [:spiff_dir] do |_, args|
    
    env_manifest_yaml = YAML.load_file(args[:spiff_dir] + '/env.yml')
    broker_ip = env_manifest_yaml['jobs'].find{|j| j['name'] == 'rmq_broker'}['networks'].first['static_ips'].first
    if got_broker_connection?(broker_ip)
      then puts '** Successfully connected to RMQ broker'
      else raise "** Cant connect to broker on #{broker_ip} **"
    end
  end

  private

  def stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_uri = if args[:stemcell_resource_uri]
      args[:stemcell_resource_uri]
    else
      'http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/vsphere/bosh-stemcell-1269-vsphere-esxi-centos.tgz'
    end

    bosh_mediator.upload_stemcell_to_director(stemcell_uri)
  end

  def got_broker_connection?(broker_ip)
    begin
      true if timeout 5 do
                          open("http://#{broker_ip}:9998/v2/catalog", 'X-Broker-Api-Version' => '2.1', :http_basic_authentication => ['admin', 'admin'], :read_timeout => 5)
                        end
    rescue
      false
    end
  end
end


namespace :riak do

  desc 'Create the Riak release'
  task :create_release do
    release_dir = File.dirname(__FILE__) + '/riak'
    bosh_mediator = create_local_bosh_mediator(release_dir)
    bosh_mediator.create_release('cf-riak-cs')
  end

  desc 'Upload and deploy the release to the BOSH director'
  task :upload_and_deploy_release, [ :core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/riak'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    
    release_manifest = BoshMediator::ReleaseManager.new.find_dev_release(release_dir)
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => YAML.load_file(release_manifest)['version'])
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.upload_dev_release(release_dir)
    bosh_mediator.deploy
  end

  desc 'Recreate Riak server 0'
  task :recreate_riak_server, [ :core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/riak'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => 'latest')
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.recreate_job('riak',0)
  end


  desc 'Register the Riak service broker with Cloud Foundry'
  task :register_service_broker, [:core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = File.dirname(__FILE__) + '/riak'
    core_manifest = args[:core_manifest]

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)

    release_manifest = BoshMediator::ReleaseManager.new.find_dev_release(release_dir)
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_release_info.merge!(:release_version => YAML.load_file(release_manifest)['version'])
    manifest_file = BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, args[:spiff_dir]).parse_and_merge_file
    bosh_mediator.set_manifest_file(manifest_file)
    bosh_mediator.run_errand 'riak_broker_registrar'
  end

  desc 'Delete the specified Riak deployment'
  task :delete_deployment, [:director_url, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)
    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], Dir.pwd)
    deployment_name = YAML.load_file(File.join(args[:spiff_dir], 'env.yml'))['name']
    bosh_mediator.delete_deployment(deployment_name)
  end

  desc 'Test the specified deployment'
  task :test_deployment, [:spiff_dir] do |_, args|
    
    env_manifest_yaml = YAML.load_file(args[:spiff_dir] + '/env.yml')
    riak_ips = env_manifest_yaml['jobs'].find{|j| j['name'] == 'riak'}['networks'].first['static_ips']
    if riak_healthcheck?(riak_ips)
      then puts '** Healthcheck on Riak Successfull'
      else raise "** Riak healthcheck failed on #{riak_ips} **"
    end
  end

  private

  def stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_uri = if args[:stemcell_resource_uri]
      args[:stemcell_resource_uri]
    else
      'http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/vsphere/bosh-stemcell-1269-vsphere-esxi-centos.tgz'
    end

    bosh_mediator.upload_stemcell_to_director(stemcell_uri)
  end

  def riak_healthcheck?(riak_ips)
    begin
      true if timeout 60 do
                            require 'riak'

                            # Create a client that uses Protocol Buffers
                            client = Riak::Client.new(:protocol => "pbc")

                            # Automatically balance between multiple nodes
                            client = Riak::Client.new(:nodes => [
                              {:host => riak_ips[0],  :pb_port => 8087},
                              {:host => riak_ips[1],  :pb_port => 8087},
                              {:host => riak_ips[2],  :pb_port => 8087},
                            ])

                            # Retrieve a bucket
                            bucket = client.bucket("doc")  # a Riak::Bucket

                            # Get an object from the bucket
                            object = bucket.get_or_new("index.html")   # a Riak::RObject

                            # Change the object's data and save
                            object.raw_data = "<html><body>Hello, world!</body></html>"
                            object.content_type = "text/html"
                            object.store

                            # Reload an object you already have
                            object.reload :force => true   # Reloads whether you have the vclock or not

                            # Access more like a hash, client[bucket][key]
                            client['doc']['index.html']   # the Riak::RObject
                        end
    rescue
      false
    end
  end
end

namespace :cf do

  desc 'Upload and deploy the release to the BOSH director'
  task :upload_and_deploy_release, [:release_file, :manifest_file, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
    args.with_defaults(:username => 'admin', :password => 'admin', :spiff_dir => nil)

    release_dir = Dir.pwd
    puts Dir.pwd
    puts release_dir
    release_file = local_release_file(args[:release_file], release_dir)

    bosh_mediator = create_bosh_mediator(args[:director_url], args[:username], args[:password], release_dir)
    stemcell_release_info = stemcell_name_and_manifest(bosh_mediator, args)
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

  private

  def stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_uri = if args[:stemcell_resource_uri]
      args[:stemcell_resource_uri]
    else
      'http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/vsphere/bosh-stemcell-1269-vsphere-esxi-centos.tgz'
    end

    bosh_mediator.upload_stemcell_to_director(stemcell_uri)
  end

  def local_release_file(release_file, release_dir)
    if release_file =~ /^http/
      download_url(release_file, File.join(release_dir, 'release-manifest.yml'))
    else
      release_file
    end
  end

end
