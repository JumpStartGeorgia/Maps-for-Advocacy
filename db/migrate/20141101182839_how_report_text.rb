class HowReportText < ActiveRecord::Migration
  def up
    # update landing page text
    PageTranslation.where(:page_id => 1)
    .update_all(
        :content => '<p>Ability.ge is a place&nbsp;for citizens to evaluate buildings, crosswalks, and other structures in&nbsp;their communities and monitor accessibility for people with disabilities. Sign up, document, and help us encourage the government and private sector to improve accessibility for all.</p>'
    )


    # add how report text
    p = Page.create(:id => 7, :name => 'how_report')
    p.page_translations.create(:locale => 'en', :title => 'How to report an accessibility violation', :content => "<ol>
    <li>Watch the <a href='/en/training_videos'>videos</a> and <a href='/en/what_is_accessibility'>learn about accessibility</a>.</li>
    <li>Take note of buildings, ramps, ATMs, and streets in your neighborhood. Take photos too!</li>
    <li>On Ability.ge, enter the location you want to evaluate. Feel free to complete more than one type of evaluation for the same place.</li>
    <li>Answer the questions and upload photos, if you have them, and submit the evaluation.</li>
    <li>We take action! We will communicate with businesses and government bodies about the rights violations that you report, making our communities more accessible for everyone.</li>
    </ol>")
    p.page_translations.create(:locale => 'ka', :title => 'How to report an accessibility violation', :content => "<ol>
    <li>Watch the <a href='/ka/training_videos'>videos</a> and <a href='/ka/what_is_accessibility'>learn about accessibility</a>.</li>
    <li>Take note of buildings, ramps, ATMs, and streets in your neighborhood. Take photos too!</li>
    <li>On Ability.ge, enter the location you want to evaluate. Feel free to complete more than one type of evaluation for the same place.</li>
    <li>Answer the questions and upload photos, if you have them, and submit the evaluation.</li>
    <li>We take action! We will communicate with businesses and government bodies about the rights violations that you report, making our communities more accessible for everyone.</li>
    </ol>")
  end

  def down
    Page.destroy(7)

    PageTranslation.where(:page_id => 1)
    .update_all(
        :content => '<p>This website monitors violations of the rights of people with disabilities in Georgia, including the right to&nbsp;accessibility,&nbsp;the right to education, and the right to health.</p><p>Ordinary people and experts can contribute information on rights violations that occur at specific venues. Please click &ldquo;Add a Place&rdquo; below to get started.</p>'
    )
  end
end
