# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

##################################
## Pages
##################################
puts "deleting all page records"
Page.delete_all
PageTranslation.delete_all

puts "creating page records"
p = Page.create(:id => 1, :name => 'landing_page')
p.page_translations.create(:locale => 'en', :title => 'About')
p.page_translations.create(:locale => 'ka', :title => 'About')
p = Page.create(:id => 2, :name => 'why_monitor')
p.page_translations.create(:locale => 'en', :title => 'Why Monitor Accessibility in Georgia?', :content => '<p class="MsoNormal">&nbsp;</p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">This site allows a coalition of disability rights advocates and active citizens to monitor implementation of the Convention on the Rights of People with Disabilities (CRPD) in Georgia. This international treaty sets legal rules to make sure that people with disabilities and people without disabilities are treated equally. Accessibility of all places is necessary to ensure equality.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>What is Accessibility?</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">When a place is accessible, it means that all people, including people with disabilities, are able to enter a place, move around inside freely, access information, and complete transactions&nbsp;<em>independently</em>&mdash;without help from others.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">All places open to the public are required by law to be accessible to all people. But right now, most places are not accessible. Some places have tried to make changes to infrastructure, but because they did not follow accessibility standards <span style="color: #000000; background-color: #ffff00;">[link to accessibility standards],</span> they are not accessible.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We cannot rely on the government to monitor the accessibility of public places. We are collecting our own information on this website in order to monitor accessibility.&nbsp;</span><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We will use this information to encourage the government and private sector to make changes. Together, we can create a more equal environment for everyone.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>What can you do?</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We need people to provide information about the accessibility of places in their neighborhoods, towns, and cities.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">3 Steps:</span></p>
<ol>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium; text-indent: -0.25in;">Learn about accessibility standards. </span><span style="background-color: #ffff00;">[link to videos]</span></li>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Fill out an evaluation.</span></li>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Take photos or video and upload them.</span></li>
</ol>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>A note</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Presently, this site monitors accessibility only for wheelchair users, blind people, and partially sighted people. We would like to expand the types of disabilities that the site covers, as well as expand the types of rights violations beyond accessibility.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">If you represent another group and would like us to expand the site to include your group, please contact us. If you have feedback about our methodology or want to be more involved in our project, please contact us. &nbsp;</span></p>')
p.page_translations.create(:locale => 'ka', :title => 'Why Monitor Accessibility in Georgia?', :content => '<p class="MsoNormal">&nbsp;</p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">This site allows a coalition of disability rights advocates and active citizens to monitor implementation of the Convention on the Rights of People with Disabilities (CRPD) in Georgia. This international treaty sets legal rules to make sure that people with disabilities and people without disabilities are treated equally. Accessibility of all places is necessary to ensure equality.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>What is Accessibility?</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">When a place is accessible, it means that all people, including people with disabilities, are able to enter a place, move around inside freely, access information, and complete transactions&nbsp;<em>independently</em>&mdash;without help from others.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">All places open to the public are required by law to be accessible to all people. But right now, most places are not accessible. Some places have tried to make changes to infrastructure, but because they did not follow accessibility standards <span style="color: #000000; background-color: #ffff00;">[link to accessibility standards],</span> they are not accessible.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We cannot rely on the government to monitor the accessibility of public places. We are collecting our own information on this website in order to monitor accessibility.&nbsp;</span><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We will use this information to encourage the government and private sector to make changes. Together, we can create a more equal environment for everyone.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>What can you do?</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">We need people to provide information about the accessibility of places in their neighborhoods, towns, and cities.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">3 Steps:</span></p>
<ol>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium; text-indent: -0.25in;">Learn about accessibility standards. </span><span style="background-color: #ffff00;">[link to videos]</span></li>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Fill out an evaluation.</span></li>
<li><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Take photos or video and upload them.</span></li>
</ol>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;"><strong>A note</strong></span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">Presently, this site monitors accessibility only for wheelchair users, blind people, and partially sighted people. We would like to expand the types of disabilities that the site covers, as well as expand the types of rights violations beyond accessibility.</span></p>
<p class="MsoNormal"><span style="font-family: arial, helvetica, sans-serif; font-size: medium;">If you represent another group and would like us to expand the site to include your group, please contact us. If you have feedback about our methodology or want to be more involved in our project, please contact us. &nbsp;</span></p>')
p = Page.create(:id => 3, :name => 'local_legislation')
p.page_translations.create(:locale => 'en', :title => 'Georgian Legislation')
p.page_translations.create(:locale => 'ka', :title => 'Georgian Legislation')
p = Page.create(:id => 4, :name => 'un_cprd')
p.page_translations.create(:locale => 'en', :title => 'United Nations Convention on the Rights of Persons with Disabilities')
p.page_translations.create(:locale => 'ka', :title => 'United Nations Convention on the Rights of Persons with Disabilities')



##################################
## Disabilities
##################################
puts "deleting all disability records"
Disability.delete_all
DisabilityTranslation.delete_all

puts "creating disability records"
d = Disability.create(:id => 1, :code => 'b', :active => true)
d.disability_translations.create(:locale => 'en', :name => 'Blind')
d.disability_translations.create(:locale => 'ka', :name => 'Blind')
d = Disability.create(:id => 2, :code => 's', :active => true)
d.disability_translations.create(:locale => 'en', :name => 'Partially Sighted')
d.disability_translations.create(:locale => 'ka', :name => 'Partially Sighted')
d = Disability.create(:id => 3, :code => 'd', :active => false)
d.disability_translations.create(:locale => 'en', :name => 'Deaf / Hard of Hearing')
d.disability_translations.create(:locale => 'ka', :name => 'Deaf / Hard of Hearing')
d = Disability.create(:id => 4, :code => 'p', :active => true)
d.disability_translations.create(:locale => 'en', :name => 'Wheelchair')
d.disability_translations.create(:locale => 'ka', :name => 'Wheelchair')


##################################
## Districts
##################################
puts "loading districts from json file"
f = File.open("#{Rails.root}/db/spreadsheets/districts.json", 'r')
msg = District.process_json_upload(f, true)
puts msg if msg.present?

=begin
puts "loading districts from csv file"
f = File.open("#{Rails.root}/db/spreadsheets/districts.csv", 'r')
msg = District.process_csv_upload(f, true)
puts msg if msg.present?
=end

puts "loading georgian district names from csv file"
f = File.open("#{Rails.root}/db/spreadsheets/district_ka_names.csv", 'r')
msg = District.process_georgian_name_csv_upload(f)
puts msg if msg.present?

=begin

##################################
## Venues
##################################
puts "loading venues from csv file"
f = File.open("#{Rails.root}/db/spreadsheets/Accessibility Upload - Venues.csv", 'r')
msg = VenueCategory.process_csv_upload(f, true)
puts msg if msg.present?



##################################
## Questions
##################################
puts "loading questions from csv file"
f = File.open("#{Rails.root}/db/spreadsheets/Accessibility Upload - Questions.csv", 'r')
msg = QuestionCategory.process_csv_upload(f, true)
puts msg if msg.present?

=end

