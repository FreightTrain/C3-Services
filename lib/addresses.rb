require 'pathname'
require 'yaml'

module Services
  class Addresses
    def initialize(spiff_dir)
      @env_path = Pathname.new(spiff_dir) + 'env.yml'
    end

    def addresses_for_job(name)
      job = YAML::load_file(@env_path.to_s)['jobs'].find{|j| j['name'] == name}
      job ? job['networks'].first['static_ips'] : []
    end
  end
end
