RSpec.describe 'features' do
  describe 'it can visit some page', type: :feature do
    it "works" do
      visit '/'

      expect(page).to have_content 'Suptasks'
      expect(page).to have_content 'All tasks belong to us'

      expect(page).to have_content '2015 Imagine Anything'
    end
  end
end
