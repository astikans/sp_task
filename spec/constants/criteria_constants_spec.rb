require 'rails_helper'

RSpec.describe CriteriaConstants do
  describe 'AVAILABLE_CRITERIA' do
    it 'contains the mapping of criteria to search classes' do
      expect(CriteriaConstants::AVAILABLE_CRITERIA).to include(
        'cheapest-direct' => 'Search::CheapestDirect',
        'cheapest' => 'Search::Cheapest',
        'fastest' => 'Search::Fastest'
      )
    end

    it 'maps to existing search classes' do
      CriteriaConstants::AVAILABLE_CRITERIA.each do |_criteria, class_name|
        expect(class_name.constantize).to be < Search::Base
      end
    end
  end
end