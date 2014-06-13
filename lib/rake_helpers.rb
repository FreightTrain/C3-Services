require_relative 'bosh_helper'

module Services

  module RakeHelpers

    def release_dir(name)
      (Pathname.new(__FILE__).parent.parent + name).to_s
    end

    def with_bosh_mediator(name, args)
      rd = release_dir(name)
      bm = Services::BoshHelper.new.bosh_mediator(args, rd)
      yield bm, rd
    end

    def bosh_task(name, service_name)
      task name, [:core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password] do |_, args|
        with_bosh_mediator(service_name, args) do |bm, release_dir|
          yield bm, release_dir, args
        end
      end
    end

    def integration_task(name, service_name)
      task name, [:core_manifest, :director_url, :stemcell_resource_uri, :spiff_dir, :username, :password, :cf_app_domain, :cf_username, :cf_password] do |_, args|
        with_bosh_mediator(service_name, args) do |bm, release_dir|
          yield test_args(args, service_name), bm
        end
      end
    end

    def test_args(args, service_name)
      {
        bosh_state: args,
        cf_credentials: {
          username: args[:cf_username],
          password: args[:cf_password],
          app_domain: args[:cf_app_domain]
        },
        release_dir: release_dir(service_name),
        service_job: service_name
      }
    end

  end
end
