require_relative 'bosh-mediator/lib/bosh_mediator_factory'
require_relative 'bosh-mediator/lib/manifest_writer'
require_relative 'bosh-mediator/lib/release_manager'

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

  private

  def stemcell_name_and_manifest(bosh_mediator, args)
    stemcell_uri = if args[:stemcell_resource_uri]
      args[:stemcell_resource_uri]
    else
      'http://bosh-jenkins-artifacts.s3.amazonaws.com/bosh-stemcell/vsphere/bosh-stemcell-1269-vsphere-esxi-centos.tgz'
    end

    bosh_mediator.upload_stemcell_to_director(stemcell_uri)
  end

end
