require_relative '../bosh-mediator/lib/bosh_mediator_factory'
require_relative '../bosh-mediator/lib/manifest_writer'
require_relative '../bosh-mediator/lib/release_manager'

module Services
  class BoshHelper

    include ::BoshMediator::BoshMediatorFactory

    def bosh_mediator(bosh_state, release_dir)
      bosh_state = {:username => 'admin', :password => 'admin', :spiff_dir => nil}.merge!(bosh_state)

      core_manifest = bosh_state[:core_manifest]

      bosh_mediator = create_bosh_mediator(bosh_state[:director_url], bosh_state[:username], bosh_state[:password], release_dir)
      if bosh_state[:stemcell_resource_uri] && bosh_state[:spiff_dir]
        stemcell_release_info = bosh_mediator.upload_stemcell_to_director(bosh_state[:stemcell_resource_uri])
        release_manifest = ::BoshMediator::ReleaseManager.new.find_dev_release(release_dir)
        stemcell_release_info.merge!(:release_version => YAML.load_file(release_manifest)['version'])
        manifest_file = ::BoshMediator::ManifestWriter.new(core_manifest, stemcell_release_info, bosh_state[:spiff_dir]).parse_and_merge_file
        bosh_mediator.set_manifest_file(manifest_file)
      end
      bosh_mediator
    end

    def local_release_file(release_file, release_dir)
      if release_file =~ /^http/
        ::BoshMediator::DownloadHelper.download_url(release_file, File.join(release_dir, 'release-manifest.yml'))
      else
        release_file
      end
    end

  end

end
