class AddAbout < ActiveRecord::Migration
  def up
    p = Page.create(:id => 9, :name => 'about')
    p.page_translations.create(:locale => 'en', :title => 'About')
    p.page_translations.create(:locale => 'ka', :title => 'About')
  end

  def down
    Page.destroy(9)
  end
end
