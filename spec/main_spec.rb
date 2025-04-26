require 'rails_helper'

RSpec.describe 'Main script' do
  let(:origin_port) { create(:port, code: 'ESBCN') }
  let(:destination_port) { create(:port, code: 'NLRTM') }
  let(:criteria) { 'cheapest' }

  describe 'input handling' do
    it 'gets input for ports and criteria' do
      expect(Inputs::Port).to receive(:input).with(port_type: 'origin port').and_return(origin_port)
      expect(Inputs::Port).to receive(:input).with(port_type: 'destination port').and_return(destination_port)
      expect(Inputs::Criteria).to receive(:input).and_return(criteria)

      load File.expand_path('../../main.rb', __FILE__)
    end
  end
end