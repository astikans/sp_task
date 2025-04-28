require 'rails_helper'

RSpec.describe 'Main script' do
  let(:origin_port) { create(:port, code: 'ESBCN') }
  let(:destination_port) { create(:port, code: 'NLRTM') }
  let(:criteria) { 'cheapest' }
  let(:search_class) { Search::Cheapest }
  let(:search_result) { double('search_result') }

  describe 'input handling' do
    before do
      # Silence awesome_print output during tests
      allow_any_instance_of(Object).to receive(:ap).and_return(nil)
    end

    it 'gets input for ports and criteria' do
      expect(Inputs::Port).to receive(:input).with(port_type: 'origin port').and_return(origin_port)
      expect(Inputs::Port).to receive(:input).with(port_type: 'destination port').and_return(destination_port)
      expect(Inputs::Criteria).to receive(:input).and_return(criteria)

      load File.expand_path('../../main.rb', __FILE__)
    end
  end

  describe 'search functionality' do
    before do
      allow(Inputs::Port).to receive(:input).with(port_type: 'origin port').and_return(origin_port)
      allow(Inputs::Port).to receive(:input).with(port_type: 'destination port').and_return(destination_port)
      allow(Inputs::Criteria).to receive(:input).and_return(criteria)
      allow(search_class).to receive(:search).and_return(search_result)
      allow(CriteriaConstants::AVAILABLE_CRITERIA).to receive(:[]).with(criteria).and_return('Search::Cheapest')
      allow_any_instance_of(String).to receive(:constantize).and_return(search_class)
      # Silence awesome_print output during tests
      allow_any_instance_of(Object).to receive(:ap).and_return(nil)
    end

    it 'uses the correct search class based on criteria' do
      class_name_string = 'Search::Cheapest'
      expect(CriteriaConstants::AVAILABLE_CRITERIA).to receive(:[]).with(criteria).and_return(class_name_string)
      expect(class_name_string).to receive(:constantize).and_return(search_class)
      expect(search_class).to receive(:search).with(origin_port, destination_port).and_return(search_result)

      load File.expand_path('../../main.rb', __FILE__)
    end
  end
end