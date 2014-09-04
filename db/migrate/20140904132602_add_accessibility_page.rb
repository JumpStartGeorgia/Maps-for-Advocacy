# encoding: UTF-8
class AddAccessibilityPage < ActiveRecord::Migration
  def up
    p = Page.create(:id => 6, :name => 'what_accessibility')
    p.page_translations.create(:locale => 'en', :title => 'What is Accessibility?')
    p.page_translations.create(:locale => 'ka', :title => 'რა არის ხელმისაწვდომობა?')
  end

  def down
    Page.find_by_id(6).destroy
  end
end
