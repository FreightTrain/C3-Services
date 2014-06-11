require_relative '../lib/rake_helpers'

module Services
  describe RakeHelpers do
    let (:rh) { Object.new.extend(RakeHelpers) }
    describe '#release_dir' do
      it 'returns a directory under the project root' do
        path = rh.release_dir('foo')
        expect(Pathname.new(path).basename.to_s).to eq 'foo'
      end
    end
    describe '#bosh_task' do
      it 'creates a rake task' do
        expect(rh).to receive(:task)
        rh.bosh_task(:hadron, 'mysql')
      end
    end
  end
end
