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
p.page_translations.create(:locale => 'en', :title => 'About', :content => '<p style="margin: 0px 0px 10px; padding: 0px; border: 0px; outline: 0px; font-size: 13px; vertical-align: baseline; font-family: arial; background: transparent;">Ac vut ac adipiscing, in placerat cras turpis in nascetur risus urna! Lundium porttitor mattis, urna cursus amet velit diam dapibus? Velit et amet! Proin facilisis lorem, nec nec vut auctor pulvinar. Mauris turpis turpis in, nisi nunc a sed porta urna vel ac nec, odio adipiscing phasellus eu dis in odio ut ac! Urna non ut porta aliquam? Tincidunt, quis velit pid turpis lectus, integer! Sit ac in nunc in pulvinar! Tincidunt cras porttitor. Proin ultricies dapibus! Et sed, et mauris, nunc tristique, in turpis placerat nec? Non mid et, porttitor odio, vel est pulvinar enim placerat urna tortor dapibus placerat, proin nunc? Cras, integer turpis lectus placerat pid, sed, ut. Risus adipiscing et pid porta integer. Elit ac.</p>')
p.page_translations.create(:locale => 'ka', :title => 'About', :content => '<p style="margin: 0px 0px 10px; padding: 0px; border: 0px; outline: 0px; font-size: 13px; vertical-align: baseline; font-family: arial; background: transparent;">Ac vut ac adipiscing, in placerat cras turpis in nascetur risus urna! Lundium porttitor mattis, urna cursus amet velit diam dapibus? Velit et amet! Proin facilisis lorem, nec nec vut auctor pulvinar. Mauris turpis turpis in, nisi nunc a sed porta urna vel ac nec, odio adipiscing phasellus eu dis in odio ut ac! Urna non ut porta aliquam? Tincidunt, quis velit pid turpis lectus, integer! Sit ac in nunc in pulvinar! Tincidunt cras porttitor. Proin ultricies dapibus! Et sed, et mauris, nunc tristique, in turpis placerat nec? Non mid et, porttitor odio, vel est pulvinar enim placerat urna tortor dapibus placerat, proin nunc? Cras, integer turpis lectus placerat pid, sed, ut. Risus adipiscing et pid porta integer. Elit ac.</p>')
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
p = Page.create(:id => 3, :name => 'georgian_legislation')
p.page_translations.create(:locale => 'en', :title => 'Georgian Legislation')
p.page_translations.create(:locale => 'ka', :title => 'Georgian Legislation')
p = Page.create(:id => 4, :name => 'un_cprd')
p.page_translations.create(:locale => 'en', :title => 'United Nations Convention on the Rights of Persons with Disabilities')
p.page_translations.create(:locale => 'ka', :title => 'United Nations Convention on the Rights of Persons with Disabilities')
p = Page.create(:id => 5, :name => 'partners')
p.page_translations.create(:locale => 'en', :title => 'Project Partners', :content => "<div>
  <a href=\"http://www.ertad.org/\" title=\"Go to ERTAD's webiste\" target=\"_blank\"><img src=\"/assets/ertad.png\" alt=\"ERTAD logo\" /></a>    
</div>
<div id=\"mariani\">
  <a href=\"https://www.facebook.com/NGOmariani\" title=\"Go to their Mariani's\" target=\"_blank\"><img src=\"/assets/mariani.jpg\" alt=\"Mariani logo\" /></a>    
</div>
<div>
  <a href=\"http://www.newmediaadvocacy.org/\" title=\"Go to NMAP's webiste\" target=\"_blank\"><img src=\"/assets/nmap.png\" alt=\"NMAP logo\" /></a>    
</div>
<div>
  <a href=\"http://jumpstart.ge/\" title=\"Go to JumpStart's webiste\" target=\"_blank\"><img src=\"/assets/jumpstart-logo.png\" title=\"JumpStart Georgia logo\" /></a>    
</div>
")
p.page_translations.create(:locale => 'ka', :title => 'Project Partners', :content => "<div>
  <a href=\"http://www.ertad.org/\" title=\"Go to ERTAD's webiste\" target=\"_blank\"><img src=\"/assets/ertad.png\" alt=\"ERTAD logo\" /></a>    
</div>
<div id=\"mariani\">
  <a href=\"https://www.facebook.com/NGOmariani\" title=\"Go to their Mariani's\" target=\"_blank\"><img src=\"/assets/mariani.jpg\" alt=\"Mariani logo\" /></a>    
</div>
<div>
  <a href=\"http://www.newmediaadvocacy.org/\" title=\"Go to NMAP's webiste\" target=\"_blank\"><img src=\"/assets/nmap.png\" alt=\"NMAP logo\" /></a>    
</div>
<div>
  <a href=\"http://jumpstart.ge/\" title=\"Go to JumpStart's webiste\" target=\"_blank\"><img src=\"/assets/jumpstart-logo.png\" title=\"JumpStart Georgia logo\" /></a>    
</div>
")



##################################
## Disabilities
##################################
puts "deleting all disability records"
Disability.delete_all
DisabilityTranslation.delete_all

puts "creating disability records"
d = Disability.create(:id => 1, :code => 'b', :active_public => true, :active_certified => true, :sort_order => 1)
d.disability_translations.create(:locale => 'en', :name => 'Blind')
d.disability_translations.create(:locale => 'ka', :name => 'Blind')
d = Disability.create(:id => 2, :code => 's', :active_public => true, :active_certified => true, :sort_order => 2)
d.disability_translations.create(:locale => 'en', :name => 'Partially Sighted')
d.disability_translations.create(:locale => 'ka', :name => 'Partially Sighted')
d = Disability.create(:id => 3, :code => 'd', :active_public => true, :active_certified => false, :sort_order => 3)
d.disability_translations.create(:locale => 'en', :name => 'Deaf')
d.disability_translations.create(:locale => 'ka', :name => 'Deaf')
d = Disability.create(:id => 4, :code => 'h', :active_public => true, :active_certified => false, :sort_order => 4)
d.disability_translations.create(:locale => 'en', :name => 'Hard of Hearing')
d.disability_translations.create(:locale => 'ka', :name => 'Hard of Hearing')
d = Disability.create(:id => 5, :code => 'm', :active_public => true, :active_certified => true, :sort_order => 5)
d.disability_translations.create(:locale => 'en', :name => 'Mobility Disability')
d.disability_translations.create(:locale => 'ka', :name => 'Mobility Disability')
d = Disability.create(:id => 6, :code => 'i', :active_public => true, :active_certified => false, :sort_order => 6)
d.disability_translations.create(:locale => 'en', :name => 'Intellectual Disability')
d.disability_translations.create(:locale => 'ka', :name => 'Intellectual Disability')


##################################
## Convention Categories
##################################
puts "deleting all convention categories"
ConventionCategory.delete_all
ConventionCategoryTranslation.delete_all

puts "creating convention category records"
cc = ConventionCategory.create(:id => 1)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Equal Recognition Before the Law')
cc.convention_category_translations.create(:locale => 'en', :name => 'Equal Recognition Before the Law')
cc = ConventionCategory.create(:id => 2, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Information and Communication')
cc.convention_category_translations.create(:locale => 'en', :name => 'Information and Communication')
cc = ConventionCategory.create(:id => 3)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Nondiscrimination')
cc.convention_category_translations.create(:locale => 'en', :name => 'Nondiscrimination')
cc = ConventionCategory.create(:id => 4, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Physical Environment/Facilities')
cc.convention_category_translations.create(:locale => 'en', :name => 'Physical Environment/Facilities')
cc = ConventionCategory.create(:id => 5)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Reasonable Accommodation')
cc.convention_category_translations.create(:locale => 'en', :name => 'Reasonable Accommodation')
cc = ConventionCategory.create(:id => 6)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Right to Education')
cc.convention_category_translations.create(:locale => 'en', :name => 'Right to Education')
cc = ConventionCategory.create(:id => 7, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Services')
cc.convention_category_translations.create(:locale => 'en', :name => 'Services')
cc = ConventionCategory.create(:id => 8, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Technology/Electronic Media')
cc.convention_category_translations.create(:locale => 'en', :name => 'Technology/Electronic Media')
cc = ConventionCategory.create(:id => 9, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'ka', :name => 'Transportation')
cc.convention_category_translations.create(:locale => 'en', :name => 'Transportation')


##################################
## Rights
##################################
puts "deleting all rights"
Right.delete_all
RightTranslation.delete_all

puts "creating rights records"
r = Right.create(:id => 1)
r.right_translations.create(:locale => 'en', :name => "Right to access to justice", :convention_article => "13")
r.right_translations.create(:locale => 'ka', :name => "Right to access to justice", :convention_article => "13")
r = Right.create(:id => 2)
r.right_translations.create(:locale => 'en', :name => "Right to control one's own financial affairs", :convention_article => "12")
r.right_translations.create(:locale => 'ka', :name => "Right to control one's own financial affairs", :convention_article => "12")
r = Right.create(:id => 3)
r.right_translations.create(:locale => 'en', :name => "Right to education", :convention_article => "24")
r.right_translations.create(:locale => 'ka', :name => "Right to education", :convention_article => "24")
r = Right.create(:id => 4)
r.right_translations.create(:locale => 'en', :name => "Right to freedom of from exploitation, violence, and abuse", :convention_article => "16")
r.right_translations.create(:locale => 'ka', :name => "Right to freedom of from exploitation, violence, and abuse", :convention_article => "16")
r = Right.create(:id => 5)
r.right_translations.create(:locale => 'en', :name => "Right to habilitation and rehabilitation", :convention_article => "26")
r.right_translations.create(:locale => 'ka', :name => "Right to habilitation and rehabilitation", :convention_article => "26")
r = Right.create(:id => 6)
r.right_translations.create(:locale => 'en', :name => "Right to have equal access to bank loans, mortgages and other forms of financial credit", :convention_article => "12")
r.right_translations.create(:locale => 'ka', :name => "Right to have equal access to bank loans, mortgages and other forms of financial credit", :convention_article => "12")
r = Right.create(:id => 7)
r.right_translations.create(:locale => 'en', :name => "Right to health", :convention_article => "25")
r.right_translations.create(:locale => 'ka', :name => "Right to health", :convention_article => "25")
r = Right.create(:id => 8)
r.right_translations.create(:locale => 'en', :name => "Right to live independently and be included in the community", :convention_article => "19")
r.right_translations.create(:locale => 'ka', :name => "Right to live independently and be included in the community", :convention_article => "19")
r = Right.create(:id => 9)
r.right_translations.create(:locale => 'en', :name => "Right to participate in cultural life, recreation, leisure and sport", :convention_article => "30")
r.right_translations.create(:locale => 'ka', :name => "Right to participate in cultural life, recreation, leisure and sport", :convention_article => "30")
r = Right.create(:id => 10)
r.right_translations.create(:locale => 'en', :name => "Right to participate in political and public life", :convention_article => "29")
r.right_translations.create(:locale => 'ka', :name => "Right to participate in political and public life", :convention_article => "29")
r = Right.create(:id => 11)
r.right_translations.create(:locale => 'en', :name => "Right to protection and safety in situations of risk", :convention_article => "11")
r.right_translations.create(:locale => 'ka', :name => "Right to protection and safety in situations of risk", :convention_article => "11")

=begin

##################################
## Districts
##################################
puts "loading districts from json file"
f = File.open("#{Rails.root}/db/spreadsheets/districts.json", 'r')
msg = District.process_json_upload(f, true)
puts msg if msg.present?

puts "loading georgian district names from csv file"
f = File.open("#{Rails.root}/db/spreadsheets/district_ka_names.csv", 'r')
msg = District.process_georgian_name_csv_upload(f)
puts msg if msg.present?

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

