# encoding: UTF-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

##################################
## Training Videos
##################################
puts "deleting all training video records"
TrainingVideo.destroy_all

puts "creating training video records"
path = "#{Rails.root}/db/images"
img = File.open("#{path}/crosswalk.png", 'r')
tr = TrainingVideo.new(:id => 1, :survey_correct_answer => false, :survey_image => img)
tr.training_video_translations.build(:locale => 'en', :title => 'Crosswalks', 
  :description => 'As you walk around your neighborhood, keep in mind these examples of accessible crosswalks.', 
  :survey_question => 'Is the overpass accessible?', 
  :video_url => 'http://youtu.be/Z6K8F7uZYYE')
tr.training_video_translations.build(:locale => 'ka', :title => 'Crosswalks', 
  :description => 'As you walk around your neighborhood, keep in mind these examples of accessible crosswalks.', 
  :survey_question => 'Is the overpass accessible?', 
  :video_url => 'http://youtu.be/WZxDKxy-OTg')
tr.save
img = File.open("#{path}/parking.png", 'r')
tr = TrainingVideo.new(:id => 2, :survey_correct_answer => true, :survey_image => img)
tr.training_video_translations.build(:locale => 'en', :title => 'Parking',
  :description => 'Is parking in your community accessible to people with disabilities?  Learn what kinds of things to watch out for.', 
  :survey_question => 'Is the parking space accessible?',
  :video_url => 'http://youtu.be/q2wMKBm5cBQ')
tr.training_video_translations.build(:locale => 'ka', :title => 'Parking',
  :description => 'Is parking in your community accessible to people with disabilities?  Learn what kinds of things to watch out for.', 
  :survey_question => 'Is the parking space accessible?',
  :video_url => 'http://youtu.be/fq5sJm3-o3s')
tr.save
img = File.open("#{path}/ramp.png", 'r')
tr = TrainingVideo.new(:id => 3, :survey_correct_answer => false, :survey_image => img)
tr.training_video_translations.build(:locale => 'en', :title => 'Ramps',
  :description => 'Can people with disabilities actually use the ramps that you see around the city? Watch the videos and find out! ', 
  :survey_question => 'Is the ramp accessible?',
  :video_url => 'http://youtu.be/nqsJlt8quTY')
tr.training_video_translations.build(:locale => 'ka', :title => 'Ramps',
  :description => 'Can people with disabilities actually use the ramps that you see around the city? Watch the videos and find out! ', 
  :survey_question => 'Is the ramp accessible?',
  :video_url => 'http://youtu.be/jAqo154b5bY')
tr.save
img = File.open("#{path}/entrance.png", 'r')
tr = TrainingVideo.new(:id => 4, :survey_correct_answer => true, :survey_image => img)
tr.training_video_translations.build(:locale => 'en', :title => 'Entrances',
  :description => 'Can a person with disabilities enter businesses and other places in your community independently?  See what makes entrances accessible to everyone.', 
  :survey_question => 'Is the entrance accessible?',
  :video_url => 'http://youtu.be/ajlLN_CG5n4')
tr.training_video_translations.build(:locale => 'ka', :title => 'Entrances',
  :description => 'Can a person with disabilities enter businesses and other places in your community independently?  See what makes entrances accessible to everyone.', 
  :survey_question => 'Is the entrance accessible?',
  :video_url => 'http://youtu.be/Xfq8gmqeJ6w')
tr.save
img = File.open("#{path}/atm.png", 'r')
tr = TrainingVideo.new(:id => 5, :survey_correct_answer => false, :survey_image => img)
tr.training_video_translations.build(:locale => 'en', :title => 'ATMs',
  :description => 'Next time you visit your local ATM, consider whether a person with disabilities would be able to use it independently--without help from other people.', 
  :survey_question => 'Is the ATM accessible?',
  :video_url => 'http://youtu.be/C1t1hDuY1Xs')
tr.training_video_translations.build(:locale => 'ka', :title => 'ATMs',
  :description => 'Next time you visit your local ATM, consider whether a person with disabilities would be able to use it independently--without help from other people.', 
  :survey_question => 'Is the ATM accessible?',
  :video_url => 'http://youtu.be/gOpvwuYM2o0')
tr.save


##################################
## Disabilities
##################################
puts "deleting all disability records"
Disability.delete_all
DisabilityTranslation.delete_all

puts "creating disability records"
d = Disability.create(:id => 1, :code => 'b', :active_public => true, :active_certified => true, :sort_order => 1)
d.disability_translations.create(:locale => 'en', :name => 'Blind')
d.disability_translations.create(:locale => 'ka', :name => 'მხედველობადაქვეითებული პირები')
d = Disability.create(:id => 2, :code => 's', :active_public => true, :active_certified => true, :sort_order => 2)
d.disability_translations.create(:locale => 'en', :name => 'Partially Sighted')
d.disability_translations.create(:locale => 'ka', :name => 'მცირემხედველი პირები')
d = Disability.create(:id => 3, :code => 'd', :active_public => true, :active_certified => false, :sort_order => 3)
d.disability_translations.create(:locale => 'en', :name => 'Deaf')
d.disability_translations.create(:locale => 'ka', :name => 'სმენადაქვეითებული პირები')
d = Disability.create(:id => 4, :code => 'h', :active_public => true, :active_certified => false, :sort_order => 4)
d.disability_translations.create(:locale => 'en', :name => 'Hard of Hearing')
d.disability_translations.create(:locale => 'ka', :name => 'სმენის ნაწილობრივი დაქვეითების მქონე პირები')
d = Disability.create(:id => 5, :code => 'm', :active_public => true, :active_certified => true, :sort_order => 5)
d.disability_translations.create(:locale => 'en', :name => 'Mobility Disability')
d.disability_translations.create(:locale => 'ka', :name => 'მობილობის შეზღუდვის მქონე პირები')
d = Disability.create(:id => 6, :code => 'i', :active_public => true, :active_certified => false, :sort_order => 6)
d.disability_translations.create(:locale => 'en', :name => 'Intellectual Disability')
d.disability_translations.create(:locale => 'ka', :name => 'ინტელექტუალური დარღვევის მქონე პირები')
d = Disability.create(:id => 7, :code => 'v', :active_public => true, :active_certified => false, :sort_order => 7)
d.disability_translations.create(:locale => 'en', :name => 'Developmental Disability')
d.disability_translations.create(:locale => 'ka', :name => 'განვითარების პრობლემების მქონე პირები')
d = Disability.create(:id => 8, :code => 'p', :active_public => true, :active_certified => false, :sort_order => 8)
d.disability_translations.create(:locale => 'en', :name => 'Psychosocial Disability')
d.disability_translations.create(:locale => 'ka', :name => 'ფსიქოსოციალური საჭიროების მქონე პირები')
d = Disability.create(:id => 9, :code => 'o', :active_public => true, :active_certified => false, :sort_order => 9)
d.disability_translations.create(:locale => 'en', :name => 'Other')
d.disability_translations.create(:locale => 'ka', :name => 'სხვა')




##################################
## Convention Categories
##################################
puts "deleting all convention categories"
ConventionCategory.delete_all
ConventionCategoryTranslation.delete_all

puts "creating convention category records"
cc = ConventionCategory.create(:id => 1)
cc.convention_category_translations.create(:locale => 'en', :name => 'Equal Recognition Before the Law')
cc.convention_category_translations.create(:locale => 'ka', :name => 'კანონის წინაშე თანასწორი აღიარება')
cc = ConventionCategory.create(:id => 2, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Information and Communication')
cc.convention_category_translations.create(:locale => 'ka', :name => 'ინფორმაცია და კომუნიკაცია')
cc = ConventionCategory.create(:id => 3)
cc.convention_category_translations.create(:locale => 'en', :name => 'Nondiscrimination')
cc.convention_category_translations.create(:locale => 'ka', :name => 'დისკრიმინაციია აღმოფხვრა')
cc = ConventionCategory.create(:id => 4, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Physical Environment/Facilities')
cc.convention_category_translations.create(:locale => 'ka', :name => 'ფიზიკური გარემო/დაწესებულებები')
cc = ConventionCategory.create(:id => 5)
cc.convention_category_translations.create(:locale => 'en', :name => 'Reasonable Accommodation')
cc.convention_category_translations.create(:locale => 'ka', :name => 'გონივრული მისადაგება')
cc = ConventionCategory.create(:id => 6)
cc.convention_category_translations.create(:locale => 'en', :name => 'Right to Education')
cc.convention_category_translations.create(:locale => 'ka', :name => 'განათლების უფლება')
cc = ConventionCategory.create(:id => 7, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Services')
cc.convention_category_translations.create(:locale => 'ka', :name => 'სერვისები')
cc = ConventionCategory.create(:id => 8, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Technology/Electronic Media')
cc.convention_category_translations.create(:locale => 'ka', :name => 'ტექნოლოგიები/ელექტრონული მედია')
cc = ConventionCategory.create(:id => 9, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Transportation')
cc.convention_category_translations.create(:locale => 'ka', :name => 'ტრანსპორტირება')
cc = ConventionCategory.create(:id => 10, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Right to Health')
cc.convention_category_translations.create(:locale => 'ka', :name => 'პირადი ცხოვრების პატივისცემის უფლება')
cc = ConventionCategory.create(:id => 11, :right_to_accessibility => true)
cc.convention_category_translations.create(:locale => 'en', :name => 'Right to Respect for Privacy')
cc.convention_category_translations.create(:locale => 'ka', :name => 'ჯანმრთელობის დაცვის უფლება')

##################################
## Rights
##################################
puts "deleting all rights"
Right.delete_all
RightTranslation.delete_all

puts "creating rights records"
r = Right.create(:id => 1)
r.right_translations.create(:locale => 'en', :name => "Right to access to justice", :convention_article => "13")
r.right_translations.create(:locale => 'ka', :name => "მართლმსაჯულების ხელმისაწვდომობის უფლება", :convention_article => "13")
r = Right.create(:id => 2)
r.right_translations.create(:locale => 'en', :name => "Right to control one's own financial affairs", :convention_article => "12")
r.right_translations.create(:locale => 'ka', :name => "საკუთარი ფინანსური საქმეების კონტროლის უფლება", :convention_article => "12")
r = Right.create(:id => 3)
r.right_translations.create(:locale => 'en', :name => "Right to education", :convention_article => "24")
r.right_translations.create(:locale => 'ka', :name => "განათლების მიღების უფლება", :convention_article => "24")
r = Right.create(:id => 4)
r.right_translations.create(:locale => 'en', :name => "Right to freedom of from exploitation, violence, and abuse", :convention_article => "16")
r.right_translations.create(:locale => 'ka', :name => "ექსპლუატაციის, ძალადობისა და შეურაცხყოფისაგან თავისუფლების უფლება", :convention_article => "16")
r = Right.create(:id => 5)
r.right_translations.create(:locale => 'en', :name => "Right to habilitation and rehabilitation", :convention_article => "26")
r.right_translations.create(:locale => 'ka', :name => "აბილიტაციისა და რეაბილიტაციის უფლება", :convention_article => "26")
r = Right.create(:id => 6)
r.right_translations.create(:locale => 'en', :name => "Right to have equal access to bank loans, mortgages and other forms of financial credit", :convention_article => "12")
r.right_translations.create(:locale => 'ka', :name => "საბანკო სესხებსა და სხვა ფინანსურ კრედიტებზე თანასწორი ხელმისაწვდომობის უფლება", :convention_article => "12")
r = Right.create(:id => 7)
r.right_translations.create(:locale => 'en', :name => "Right to health", :convention_article => "25")
r.right_translations.create(:locale => 'ka', :name => "ჯანმრთელობის დაცვის უფლება", :convention_article => "25")
r = Right.create(:id => 8)
r.right_translations.create(:locale => 'en', :name => "Right to live independently and be included in the community", :convention_article => "19")
r.right_translations.create(:locale => 'ka', :name => "დამოუკიდებელი ცხოვრებისა და საზოგადოებაში ჩართვის უფლება", :convention_article => "19")
r = Right.create(:id => 9)
r.right_translations.create(:locale => 'en', :name => "Right to participate in cultural life, recreation, leisure and sport", :convention_article => "30")
r.right_translations.create(:locale => 'ka', :name => "კულტურულ, სპორტულ, გასართობ ღონისძიებებში მონაწილეობის  უფლება", :convention_article => "30")
r = Right.create(:id => 10)
r.right_translations.create(:locale => 'en', :name => "Right to participate in political and public life", :convention_article => "29")
r.right_translations.create(:locale => 'ka', :name => "პოლიტიკურ და საზოგადოებრივ ცხოვრებაში მონაწილეობის უფლება", :convention_article => "29")
r = Right.create(:id => 11)
r.right_translations.create(:locale => 'en', :name => "Right to protection and safety in situations of risk", :convention_article => "11")
r.right_translations.create(:locale => 'ka', :name => "რისკის შემცველ სიტუაციებში დაცვისა და უსაფრთხოების უფლება", :convention_article => "11")

=begin
##################################
## Organizations
##################################
puts "deleting all organizations"
Organization.delete_all
OrganizationTranslation.delete_all

puts "creating organization records"
o = Organization.create(:id => 1, :url => 'http://jumpstart.ge/')
o.organization_translations.create(:locale => 'en', :name => "JumpStart Georgia")
o.organization_translations.create(:locale => 'ka', :name => "JumpStart Georgia")
o = Organization.create(:id => 2, :url => 'http://www.newmediaadvocacy.org/')
o.organization_translations.create(:locale => 'en', :name => "New Media Advocacy Project")
o.organization_translations.create(:locale => 'ka', :name => "New Media Advocacy Project")
o = Organization.create(:id => 3, :url => 'http://www.ertad.org/')
o.organization_translations.create(:locale => 'en', :name => "Accessible Environment for Everyone")
o.organization_translations.create(:locale => 'ka', :name => "ხელმისაწვდომი გარემო ყველასათვის")
o = Organization.create(:id => 4, :url => 'https://www.facebook.com/NGOmariani')
o.organization_translations.create(:locale => 'en', :name => "Mariani")
o.organization_translations.create(:locale => 'ka', :name => "მარიანი")
=end

=begin
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
p = Page.create(:id => 6, :name => 'what_accessibility')
p.page_translations.create(:locale => 'en', :title => 'What is Accessibility?')
p.page_translations.create(:locale => 'ka', :title => 'რა არის ხელმისაწვდომობა?')
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
