require 'spec_helper'


RSpec.describe 'features' do
  describe 'it can visit some page', type: :feature do
    it "works" do
      visit '/'

      expect(page).to have_content 'Suptasks'

      expect(page).to have_content '2015 Imagine Anything'
    end
  end
end
