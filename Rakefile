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

  desc 'Delete the specified deployment'
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
