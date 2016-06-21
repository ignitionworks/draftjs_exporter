RSpec.describe 'requires' do
  describe 'draftjs_exporter' do
    it 'can be required' do
      expect(require('draftjs_exporter')).to be
    end
  end

  describe 'draftjs_exporter/version' do
    it 'can be required' do
      expect(require('draftjs_exporter/version')).to be
    end
  end
end
