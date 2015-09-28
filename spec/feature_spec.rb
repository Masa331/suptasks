require 'spec_helper'


RSpec.describe 'User' do
  describe 'signs in', type: :feature do
    before do 
      OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
        :provider => 'twitter',
        :uid => '123545'
        # etc.
        #     })
    end
    it "works" do
      visit '/'

      expect(page).to have_content 'Suptasks'

      expect(page).to have_content '2015 Imagine Anything'
    end
  end
end
