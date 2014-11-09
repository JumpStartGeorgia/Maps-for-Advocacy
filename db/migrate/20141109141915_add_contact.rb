class AddContact < ActiveRecord::Migration
  def up
    p = Page.create(:id => 8, :name => 'contact')
    p.page_translations.create(:locale => 'en', :title => 'Contact', :content => "<p>If you or your organization would like to help us improve Ability.ge, or if you would be interested in hosting an Ability.ge workshop, please don't hesitate to contact us!&nbsp;</p>
    <p>&nbsp;</p>
    <p>New Media Advocacy Project:&nbsp;<br />Elizabeth Summers &nbsp; &nbsp; &nbsp;<br /><a href='mailto:elizabeth@newmediaadvocacy.org'>elizabeth@newmediaadvocacy.org</a></p>
    <p>&nbsp;</p>
    <p>JumpStart Georgia:&nbsp;<br />Eric Barrett &nbsp; &nbsp; &nbsp;<br /><a href='mailto:eric@jumpstart.ge'>eric@jumpstart.ge</a></p>")
    p.page_translations.create(:locale => 'ka', :title => 'Contact', :content => "<p>If you or your organization would like to help us improve Ability.ge, or if you would be interested in hosting an Ability.ge workshop, please don't hesitate to contact us!&nbsp;</p>
    <p>&nbsp;</p>
    <p>New Media Advocacy Project:&nbsp;<br />Elizabeth Summers &nbsp; &nbsp; &nbsp;<br /><a href='mailto:elizabeth@newmediaadvocacy.org'>elizabeth@newmediaadvocacy.org</a></p>
    <p>&nbsp;</p>
    <p>JumpStart Georgia:&nbsp;<br />Eric Barrett &nbsp; &nbsp; &nbsp;<br /><a href='mailto:eric@jumpstart.ge'>eric@jumpstart.ge</a></p>")
  end

  def down
    Page.destroy(8)
  end
end
