# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

##################################
## Disabilities
##################################
puts "deleting all disability records"
Disability.delete_all
DisabilityTranslation.delete_all

puts "creating disability records"
d = Disability.create(:id => 1, :code => 'b')
d.disability_translations.create(:locale => 'en', :name => 'Blind')
d.disability_translations.create(:locale => 'ka', :name => 'Blind')
d = Disability.create(:id => 2, :code => 's')
d.disability_translations.create(:locale => 'en', :name => 'Partially Sighted')
d.disability_translations.create(:locale => 'ka', :name => 'Partially Sighted')
d = Disability.create(:id => 3, :code => 'd')
d.disability_translations.create(:locale => 'en', :name => 'Deaf / Hard of Hearing')
d.disability_translations.create(:locale => 'ka', :name => 'Deaf / Hard of Hearing')
d = Disability.create(:id => 4, :code => 'p')
d.disability_translations.create(:locale => 'en', :name => 'Physical (wheelchair)')
d.disability_translations.create(:locale => 'ka', :name => 'Physical (wheelchair)')


=begin
##################################
## Questions
##################################
puts "deleting all question records"
QuestionCategory.delete_all
QuestionCategoryTranslation.delete_all
Question.delete_all
QuestionTranslation.delete_all
QuestionPairing.delete_all
QuestionPairingTranslation.delete_all

puts "creating question records"

# parking
qc = QuestionCategory.create(:id => 1, :is_common => true, :sort_order => 1)
qc.question_category_translations.create(:locale => 'en', :name => 'Parking')
qc.question_category_translations.create(:locale => 'ka', :name => 'Parking')
q = Question.create(:id => 1)
q.question_translations.create(:locale => 'en', :name => 'Designated parking or drop off area')
q.question_translations.create(:locale => 'ka', :name => 'Designated parking or drop off area')
QuestionPairing.create(:id => 1, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 2)
q.question_translations.create(:locale => 'en', :name => 'Is unobstructed')
q.question_translations.create(:locale => 'ka', :name => 'Is unobstructed')
QuestionPairing.create(:id => 2, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 3)
q.question_translations.create(:locale => 'en', :name => 'Accessible route from parking to entrance')
q.question_translations.create(:locale => 'ka', :name => 'Accessible route from parking to entrance')
QuestionPairing.create(:id => 3, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)

# entrace
qc = QuestionCategory.create(:id => 2, :is_common => true, :sort_order => 2)
qc.question_category_translations.create(:locale => 'en', :name => 'Entrance')
qc.question_category_translations.create(:locale => 'ka', :name => 'Entrance')
q = Question.create(:id => 4)
q.question_translations.create(:locale => 'en', :name => 'Doorways with ramps')
q.question_translations.create(:locale => 'ka', :name => 'Doorways with ramps')
qp = QuestionPairing.create(:id => 4, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
qp.question_pairing_translations.create(:locale => 'en', :evidence => 'Angle')
qp.question_pairing_translations.create(:locale => 'ka', :evidence => 'Angle')
q = Question.create(:id => 6)
q.question_translations.create(:locale => 'en', :name => 'Flat doorway')
q.question_translations.create(:locale => 'ka', :name => 'Flat doorway')
QuestionPairing.create(:id => 6, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 7)
q.question_translations.create(:locale => 'en', :name => 'Wide doors')
q.question_translations.create(:locale => 'ka', :name => 'Wide doors')
qp = QuestionPairing.create(:id => 7, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)
qp.question_pairing_translations.create(:locale => 'en', :evidence => 'Width (m)')
qp.question_pairing_translations.create(:locale => 'ka', :evidence => 'Width (m)')
q = Question.create(:id => 8)
q.question_translations.create(:locale => 'en', :name => 'Tactile map of building')
q.question_translations.create(:locale => 'ka', :name => 'Tactile map of building')
QuestionPairing.create(:id => 8, :question_category_id => qc.id, :question_id => q.id, :sort_order => 4)

#restroom
qc = QuestionCategory.create(:id => 3, :is_common => true, :sort_order => 3)
qc.question_category_translations.create(:locale => 'en', :name => 'Restroom')
qc.question_category_translations.create(:locale => 'ka', :name => 'Restroom')
q = Question.create(:id => 9)
q.question_translations.create(:locale => 'en', :name => 'Adapted restroom with wide door and grab bar')
q.question_translations.create(:locale => 'ka', :name => 'Adapted restroom with wide door and grab bar')
QuestionPairing.create(:id => 9, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 10)
q.question_translations.create(:locale => 'en', :name => 'Designated as accessible')
q.question_translations.create(:locale => 'ka', :name => 'Designated as accessible')
QuestionPairing.create(:id => 10, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 26)
q.question_translations.create(:locale => 'en', :name => 'Sufficient space in the interior')
q.question_translations.create(:locale => 'ka', :name => 'Sufficient space in the interior')
QuestionPairing.create(:id => 26, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)

# elevators
qc = QuestionCategory.create(:id => 4, :is_common => true, :sort_order => 4)
qc.question_category_translations.create(:locale => 'en', :name => 'Elevators')
qc.question_category_translations.create(:locale => 'ka', :name => 'Elevators')
q = Question.create(:id => 11)
q.question_translations.create(:locale => 'en', :name => 'Exists')
q.question_translations.create(:locale => 'ka', :name => 'Exists')
QuestionPairing.create(:id => 11, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 12)
q.question_translations.create(:locale => 'en', :name => 'Accessible')
q.question_translations.create(:locale => 'ka', :name => 'Accessible')
QuestionPairing.create(:id => 12, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
qp = QuestionPairing.create(:id => 13, :question_category_id => qc.id, :question_id => 7, :sort_order => 3)
qp.question_pairing_translations.create(:locale => 'en', :evidence => 'Width (m)')
qp.question_pairing_translations.create(:locale => 'ka', :evidence => 'Width (m)')
QuestionPairing.create(:id => 14, :question_category_id => qc.id, :question_id => 6, :sort_order => 4)
QuestionPairing.create(:id => 15, :question_category_id => qc.id, :question_id => 2, :sort_order => 5)
q = Question.create(:id => 16)
q.question_translations.create(:locale => 'en', :name => 'Braille buttons')
q.question_translations.create(:locale => 'ka', :name => 'Braille buttons')
QuestionPairing.create(:id => 16, :question_category_id => qc.id, :question_id => q.id, :sort_order => 6)
q = Question.create(:id => 17)
q.question_translations.create(:locale => 'en', :name => 'High contrast markings')
q.question_translations.create(:locale => 'ka', :name => 'High contrast markings')
QuestionPairing.create(:id => 17, :question_category_id => qc.id, :question_id => q.id, :sort_order => 7)
q = Question.create(:id => 18)
q.question_translations.create(:locale => 'en', :name => 'Audio indicator of floor and direction of elevator')
q.question_translations.create(:locale => 'ka', :name => 'Audio indicator of floor and direction of elevator')
QuestionPairing.create(:id => 18, :question_category_id => qc.id, :question_id => q.id, :sort_order => 8)

# stairs
qc = QuestionCategory.create(:id => 5, :is_common => true, :sort_order => 5)
qc.question_category_translations.create(:locale => 'en', :name => 'Stairs')
qc.question_category_translations.create(:locale => 'ka', :name => 'Stairs')
q = Question.create(:id => 19)
q.question_translations.create(:locale => 'en', :name => 'Markings on every first and last step on staircases')
q.question_translations.create(:locale => 'ka', :name => 'Markings on every first and last step on staircases')
QuestionPairing.create(:id => 19, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 20)
q.question_translations.create(:locale => 'en', :name => 'Handrails different color from staircases')
q.question_translations.create(:locale => 'ka', :name => 'Handrails different color from staircases')
QuestionPairing.create(:id => 20, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)


# escalators
qc = QuestionCategory.create(:id => 6, :is_common => true, :sort_order => 6)
qc.question_category_translations.create(:locale => 'en', :name => 'Escalators')
qc.question_category_translations.create(:locale => 'ka', :name => 'Escalators')

#seating area
qc = QuestionCategory.create(:id => 7, :is_common => true, :sort_order => 7)
qc.question_category_translations.create(:locale => 'en', :name => 'Seating Area')
qc.question_category_translations.create(:locale => 'ka', :name => 'Seating Area')
q = Question.create(:id => 21)
q.question_translations.create(:locale => 'en', :name => 'Appropriate width and height that is accessible for wheelchairs')
q.question_translations.create(:locale => 'ka', :name => 'Appropriate width and height that is accessible for wheelchairs')
QuestionPairing.create(:id => 21, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

#in print
qc = QuestionCategory.create(:id => 8, :is_common => true, :sort_order => 8)
qc.question_category_translations.create(:locale => 'en', :name => 'In Print')
qc.question_category_translations.create(:locale => 'ka', :name => 'In Print')
q = Question.create(:id => 22)
q.question_translations.create(:locale => 'en', :name => 'Available in large print')
q.question_translations.create(:locale => 'ka', :name => 'Available in large print')
qp = QuestionPairing.create(:id => 22, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
qp.question_pairing_translations.create(:locale => 'en', :evidence => 'Font size')
qp.question_pairing_translations.create(:locale => 'ka', :evidence => 'Font size')
q = Question.create(:id => 23)
q.question_translations.create(:locale => 'en', :name => 'In Braille')
q.question_translations.create(:locale => 'ka', :name => 'In Braille')
QuestionPairing.create(:id => 23, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)


# service provider
qc = QuestionCategory.create(:id => 9, :is_common => true, :sort_order => 9)
qc.question_category_translations.create(:locale => 'en', :name => 'Service Provider')
qc.question_category_translations.create(:locale => 'ka', :name => 'Service Provider')
q = Question.create(:id => 24)
q.question_translations.create(:locale => 'en', :name => 'At least one desk with wheelchair adapted (low) height')
q.question_translations.create(:locale => 'ka', :name => 'At least one desk with wheelchair adapted (low) height')
QuestionPairing.create(:id => 24, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

# other
qc = QuestionCategory.create(:id => 10, :is_common => true, :sort_order => 10)
qc.question_category_translations.create(:locale => 'en', :name => 'Other')
qc.question_category_translations.create(:locale => 'ka', :name => 'Other')
q = Question.create(:id => 25)
q.question_translations.create(:locale => 'en', :name => 'Special services available for disabled persons')
q.question_translations.create(:locale => 'ka', :name => 'Special services available for disabled persons')
QuestionPairing.create(:id => 25, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)


puts "done question records"


##################################
## Venues
##################################
puts "deleting all venue records"
VenueCategory.delete_all
VenueCategoryTranslation.delete_all
Venue.delete_all
VenueTranslation.delete_all

puts "creating venue records"

# food and drink
vc = VenueCategory.create(:id => 1, :sort_order => 1)
vc.venue_category_translations.create(:locale => 'en', :name => 'Food and Drink')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Food and Drink')
v = Venue.create(:id => 1, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Cafe / Bars')
v.venue_translations.create(:locale => 'ka', :name => 'Cafe / Bars')
v = Venue.create(:id => 2, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Restaurants')
v.venue_translations.create(:locale => 'ka', :name => 'Restaurants')
v = Venue.create(:id => 3, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Fast Food')
v.venue_translations.create(:locale => 'ka', :name => 'Fast Food')
v = Venue.create(:id => 4, :venue_category_id => vc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Market')
v.venue_translations.create(:locale => 'ka', :name => 'Market')
v = Venue.create(:id => 5, :venue_category_id => vc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Grocerty Store')
v.venue_translations.create(:locale => 'ka', :name => 'Grocerty Store')

# Financial Institutions and services
vc = VenueCategory.create(:id => 2, :sort_order => 2)
vc.venue_category_translations.create(:locale => 'en', :name => 'Financial Institutions and Services')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Financial Institutions and Services')
qc = QuestionCategory.create(:id => 11, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Banks')
qc.question_category_translations.create(:locale => 'ka', :name => 'Banks')
v = Venue.create(:id => 6, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Banks')
v.venue_translations.create(:locale => 'ka', :name => 'Banks')
QuestionPairing.create(:id => 27, :question_category_id => qc.id, :question_id => 24, :sort_order => 1)
q = Question.create(:id => 28)
q.question_translations.create(:locale => 'en', :name => 'Queue number monitors large and easy to read')
q.question_translations.create(:locale => 'ka', :name => 'Queue number monitors large and easy to read')
QuestionPairing.create(:id => 28, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 29)
q.question_translations.create(:locale => 'en', :name => 'Independently complete: withdrawal')
q.question_translations.create(:locale => 'ka', :name => 'Independently complete: withdrawal')
QuestionPairing.create(:id => 29, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)
q = Question.create(:id => 30)
q.question_translations.create(:locale => 'en', :name => 'Independently complete: deposit')
q.question_translations.create(:locale => 'ka', :name => 'Independently complete: deposit')
QuestionPairing.create(:id => 30, :question_category_id => qc.id, :question_id => q.id, :sort_order => 4)
q = Question.create(:id => 31)
q.question_translations.create(:locale => 'en', :name => 'Independently complete: opening account')
q.question_translations.create(:locale => 'ka', :name => 'Independently complete: opening account')
QuestionPairing.create(:id => 31, :question_category_id => qc.id, :question_id => q.id, :sort_order => 5)
q = Question.create(:id => 32)
q.question_translations.create(:locale => 'en', :name => 'Independently complete: obtaining official documents')
q.question_translations.create(:locale => 'ka', :name => 'Independently complete: obtaining official documents')
QuestionPairing.create(:id => 32, :question_category_id => qc.id, :question_id => q.id, :sort_order => 6)
q = Question.create(:id => 33)
q.question_translations.create(:locale => 'en', :name => 'Independently complete: other transactions')
q.question_translations.create(:locale => 'ka', :name => 'Independently complete: other transactions')
QuestionPairing.create(:id => 33, :question_category_id => qc.id, :question_id => q.id, :sort_order => 7)


qc = QuestionCategory.create(:id => 12, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'ATMs and Pay Boxes')
qc.question_category_translations.create(:locale => 'ka', :name => 'ATMs and Pay Boxes')
v = Venue.create(:id => 7, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'ATMs and Pay Boxes')
v.venue_translations.create(:locale => 'ka', :name => 'ATMs and Pay Boxes')
q = Question.create(:id => 34)
q.question_translations.create(:locale => 'en', :name => 'Accessible path to the machine')
q.question_translations.create(:locale => 'ka', :name => 'Accessible path to the machine')
QuestionPairing.create(:id => 34, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 35)
q.question_translations.create(:locale => 'en', :name => 'Appropriate height for wheelchair accessibility')
q.question_translations.create(:locale => 'ka', :name => 'Appropriate height for wheelchair accessibility')
QuestionPairing.create(:id => 35, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 36)
q.question_translations.create(:locale => 'en', :name => 'Minimal glare')
q.question_translations.create(:locale => 'ka', :name => 'Minimal glare')
QuestionPairing.create(:id => 36, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)
q = Question.create(:id => 37)
q.question_translations.create(:locale => 'en', :name => 'Visible screen')
q.question_translations.create(:locale => 'ka', :name => 'Visible screen')
QuestionPairing.create(:id => 37, :question_category_id => qc.id, :question_id => q.id, :sort_order => 4)
qp = QuestionPairing.create(:id => 38, :question_category_id => qc.id, :question_id => 22, :sort_order => 5)
qp.question_pairing_translations.create(:locale => 'en', :evidence => 'Font size')
qp.question_pairing_translations.create(:locale => 'ka', :evidence => 'Font size')
q = Question.create(:id => 39)
q.question_translations.create(:locale => 'en', :name => 'High contrast')
q.question_translations.create(:locale => 'ka', :name => 'High contrast')
QuestionPairing.create(:id => 39, :question_category_id => qc.id, :question_id => q.id, :sort_order => 6)
q = Question.create(:id => 40)
q.question_translations.create(:locale => 'en', :name => 'Talking ATM or headphone jack for audio')
q.question_translations.create(:locale => 'ka', :name => 'Talking ATM or headphone jack for audio')
QuestionPairing.create(:id => 40, :question_category_id => qc.id, :question_id => q.id, :sort_order => 7)


v = Venue.create(:id => 8, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Currency Exchange')
v.venue_translations.create(:locale => 'ka', :name => 'Currency Exchange')


#Sports and Entertainment
vc = VenueCategory.create(:id => 3, :sort_order => 3)
vc.venue_category_translations.create(:locale => 'en', :name => 'Sports and Entertainment')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Sports and Entertainment')

qc = QuestionCategory.create(:id => 13, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Cinema / Theaters')
qc.question_category_translations.create(:locale => 'ka', :name => 'Cinema / Theaters')
v = Venue.create(:id => 9, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Cinema / Theaters')
v.venue_translations.create(:locale => 'ka', :name => 'Cinema / Theaters')
q = Question.create(:id => 41)
q.question_translations.create(:locale => 'en', :name => 'Reserved area for wheelchairs')
q.question_translations.create(:locale => 'ka', :name => 'Reserved area for wheelchairs')
QuestionPairing.create(:id => 41, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 14, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Casinos')
qc.question_category_translations.create(:locale => 'ka', :name => 'Casinos')
v = Venue.create(:id => 10, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Casinos')
v.venue_translations.create(:locale => 'ka', :name => 'Casinos')
QuestionPairing.create(:id => 42, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 15, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Galleries')
qc.question_category_translations.create(:locale => 'ka', :name => 'Galleries')
v = Venue.create(:id => 11, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Galleries')
v.venue_translations.create(:locale => 'ka', :name => 'Galleries')
QuestionPairing.create(:id => 43, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 16, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Clubs')
qc.question_category_translations.create(:locale => 'ka', :name => 'Clubs')
v = Venue.create(:id => 12, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Clubs')
v.venue_translations.create(:locale => 'ka', :name => 'Clubs')
QuestionPairing.create(:id => 44, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 17, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Museums')
qc.question_category_translations.create(:locale => 'ka', :name => 'Museums')
v = Venue.create(:id => 13, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Museums')
v.venue_translations.create(:locale => 'ka', :name => 'Museums')
QuestionPairing.create(:id => 45, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 18, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Stadiums')
qc.question_category_translations.create(:locale => 'ka', :name => 'Stadiums')
v = Venue.create(:id => 14, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 6)
v.venue_translations.create(:locale => 'en', :name => 'Stadiums')
v.venue_translations.create(:locale => 'ka', :name => 'Stadiums')
QuestionPairing.create(:id => 46, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)




#Healthcare
vc = VenueCategory.create(:id => 4, :sort_order => 4)
vc.venue_category_translations.create(:locale => 'en', :name => 'Healthcare')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Healthcare')
v = Venue.create(:id => 15, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Pharmacy')
v.venue_translations.create(:locale => 'ka', :name => 'Pharmacy')
v = Venue.create(:id => 16, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Dentist')
v.venue_translations.create(:locale => 'ka', :name => 'Dentist')
v = Venue.create(:id => 17, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Hospital')
v.venue_translations.create(:locale => 'ka', :name => 'Hospital')


#emergency
vc = VenueCategory.create(:id => 5, :sort_order => 5)
vc.venue_category_translations.create(:locale => 'en', :name => 'Emergency')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Emergency')
v = Venue.create(:id => 18, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => '112')
v.venue_translations.create(:locale => 'ka', :name => '112')


#Government
vc = VenueCategory.create(:id => 6, :sort_order => 6)
vc.venue_category_translations.create(:locale => 'en', :name => 'Government')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Government')
v = Venue.create(:id => 19, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Courthouses')
v.venue_translations.create(:locale => 'ka', :name => 'Courthouses')
v = Venue.create(:id => 20, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Embassies')
v.venue_translations.create(:locale => 'ka', :name => 'Embassies')
v = Venue.create(:id => 21, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'City Halls')
v.venue_translations.create(:locale => 'ka', :name => 'City Halls')
v = Venue.create(:id => 22, :venue_category_id => vc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Prisons')
v.venue_translations.create(:locale => 'ka', :name => 'Prisons')
v = Venue.create(:id => 23, :venue_category_id => vc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Police Stations')
v.venue_translations.create(:locale => 'ka', :name => 'Police Stations')


#Lodging
vc = VenueCategory.create(:id => 7, :sort_order => 7)
vc.venue_category_translations.create(:locale => 'en', :name => 'Lodging')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Lodging')
v = Venue.create(:id => 24, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Hotels')
v.venue_translations.create(:locale => 'ka', :name => 'Hotels')
v = Venue.create(:id => 25, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Hostels')
v.venue_translations.create(:locale => 'ka', :name => 'Hostels')


#Public Services
vc = VenueCategory.create(:id => 8, :sort_order => 8)
vc.venue_category_translations.create(:locale => 'en', :name => 'Public Services')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Public Services')
v = Venue.create(:id => 26, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Libraries')
v.venue_translations.create(:locale => 'ka', :name => 'Libraries')
v = Venue.create(:id => 27, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Post-offices')
v.venue_translations.create(:locale => 'ka', :name => 'Post-offices')
v = Venue.create(:id => 28, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Revenue Services')
v.venue_translations.create(:locale => 'ka', :name => 'Revenue Services')
v = Venue.create(:id => 29, :venue_category_id => vc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Justice House')
v.venue_translations.create(:locale => 'ka', :name => 'Justice House')
v = Venue.create(:id => 30, :venue_category_id => vc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Legal Aid Offices')
v.venue_translations.create(:locale => 'ka', :name => 'Legal Aid Offices')


#Place of Worship
vc = VenueCategory.create(:id => 9, :sort_order => 9)
vc.venue_category_translations.create(:locale => 'en', :name => 'Places of Worship')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Places of Worship')


#Education
vc = VenueCategory.create(:id => 10, :sort_order => 10)
vc.venue_category_translations.create(:locale => 'en', :name => 'Education')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Education')
qc = QuestionCategory.create(:id => 19, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Kindergartens')
qc.question_category_translations.create(:locale => 'ka', :name => 'Kindergartens')
v = Venue.create(:id => 31, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Kindergartens')
v.venue_translations.create(:locale => 'ka', :name => 'Kindergartens')
q = Question.create(:id => 47)
q.question_translations.create(:locale => 'en', :name => 'Aadapted desks with appropriate height and structure')
q.question_translations.create(:locale => 'ka', :name => 'Adapted desks with appropriate height and structure')
QuestionPairing.create(:id => 47, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 20, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Schools')
qc.question_category_translations.create(:locale => 'ka', :name => 'Schools')
v = Venue.create(:id => 32, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Schools')
v.venue_translations.create(:locale => 'ka', :name => 'Schools')
QuestionPairing.create(:id => 48, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 21, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Colleges')
qc.question_category_translations.create(:locale => 'ka', :name => 'Colleges')
v = Venue.create(:id => 33, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Colleges')
v.venue_translations.create(:locale => 'ka', :name => 'Colleges')
QuestionPairing.create(:id => 49, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)

qc = QuestionCategory.create(:id => 22, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Universities')
qc.question_category_translations.create(:locale => 'ka', :name => 'Universities')
v = Venue.create(:id => 34, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Universities')
v.venue_translations.create(:locale => 'ka', :name => 'Universities')
QuestionPairing.create(:id => 50, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)


#General Business
vc = VenueCategory.create(:id => 11, :sort_order => 11)
vc.venue_category_translations.create(:locale => 'en', :name => 'General Business')
vc.venue_category_translations.create(:locale => 'ka', :name => 'General Business')


#Recreational Area
vc = VenueCategory.create(:id => 12, :sort_order => 12)
vc.venue_category_translations.create(:locale => 'en', :name => 'Recreational Area')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Recreational Area')
v = Venue.create(:id => 35, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Beach')
v.venue_translations.create(:locale => 'ka', :name => 'Beach')
v = Venue.create(:id => 36, :venue_category_id => vc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Gardens / Parks')
v.venue_translations.create(:locale => 'ka', :name => 'Gardens / Parks')
v = Venue.create(:id => 37, :venue_category_id => vc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Amusement Parks')
v.venue_translations.create(:locale => 'ka', :name => 'Amusement Parks')
v = Venue.create(:id => 38, :venue_category_id => vc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Zoo')
v.venue_translations.create(:locale => 'ka', :name => 'Zoo')
v = Venue.create(:id => 39, :venue_category_id => vc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Museums')
v.venue_translations.create(:locale => 'ka', :name => 'Museums')
v = Venue.create(:id => 40, :venue_category_id => vc.id, :sort_order => 6)
v.venue_translations.create(:locale => 'en', :name => 'Historical Landmarks (not places of worship)')
v.venue_translations.create(:locale => 'ka', :name => 'Historical Landmarks (not places of worship)')


#Transportation
vc = VenueCategory.create(:id => 13, :sort_order => 13)
vc.venue_category_translations.create(:locale => 'en', :name => 'Transportation')
vc.venue_category_translations.create(:locale => 'ka', :name => 'Transportation')
v = Venue.create(:id => 41, :venue_category_id => vc.id, :sort_order => 1)
v.venue_translations.create(:locale => 'en', :name => 'Crosswalks')
v.venue_translations.create(:locale => 'ka', :name => 'Crosswalks')

qc = QuestionCategory.create(:id => 23, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Public Buses')
qc.question_category_translations.create(:locale => 'ka', :name => 'Public Buses')
v = Venue.create(:id => 43, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 2)
v.venue_translations.create(:locale => 'en', :name => 'Sidewalks')
v.venue_translations.create(:locale => 'ka', :name => 'Sidewalks')
q = Question.create(:id => 57)
QuestionPairing.create(:id => 57, :question_category_id => qc.id, :question_id => 2, :sort_order => 1)
q = Question.create(:id => 58)
q.question_translations.create(:locale => 'en', :name => 'Is in usable condition')
q.question_translations.create(:locale => 'ka', :name => 'Is in usable condition')
QuestionPairing.create(:id => 58, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)


qc = QuestionCategory.create(:id => 24, :is_common => false)
qc.question_category_translations.create(:locale => 'en', :name => 'Public Buses')
qc.question_category_translations.create(:locale => 'ka', :name => 'Public Buses')
v = Venue.create(:id => 42, :venue_category_id => vc.id, :question_category_id => qc.id, :sort_order => 3)
v.venue_translations.create(:locale => 'en', :name => 'Public Buses')
v.venue_translations.create(:locale => 'ka', :name => 'Public Buses')
q = Question.create(:id => 51)
q.question_translations.create(:locale => 'en', :name => 'Accessible path to bus stop')
q.question_translations.create(:locale => 'ka', :name => 'Accessible path to bus stop')
QuestionPairing.create(:id => 51, :question_category_id => qc.id, :question_id => q.id, :sort_order => 1)
q = Question.create(:id => 52)
q.question_translations.create(:locale => 'en', :name => 'Sign listing upcoming buses has audio component')
q.question_translations.create(:locale => 'ka', :name => 'Sign listing upcoming buses has audio component')
QuestionPairing.create(:id => 52, :question_category_id => qc.id, :question_id => q.id, :sort_order => 2)
q = Question.create(:id => 53)
q.question_translations.create(:locale => 'en', :name => 'Buses announce the stops')
q.question_translations.create(:locale => 'ka', :name => 'Buses announce the stops')
QuestionPairing.create(:id => 53, :question_category_id => qc.id, :question_id => q.id, :sort_order => 3)
q = Question.create(:id => 54)
q.question_translations.create(:locale => 'en', :name => 'A way to hear which number bus is arriving (bus should say it as it arrives)')
q.question_translations.create(:locale => 'ka', :name => 'A way to hear which number bus is arriving (bus should say it as it arrives)')
QuestionPairing.create(:id => 54, :question_category_id => qc.id, :question_id => q.id, :sort_order => 4)
q = Question.create(:id => 55)
q.question_translations.create(:locale => 'en', :name => 'Driver stops bus so door be in front of blind person w/ cane or dog')
q.question_translations.create(:locale => 'ka', :name => 'Driver stops bus so door be in front of blind person w/ cane or dog')
QuestionPairing.create(:id => 55, :question_category_id => qc.id, :question_id => q.id, :sort_order => 5)
q = Question.create(:id => 56)
q.question_translations.create(:locale => 'en', :name => 'Bus stop signs are easy to read')
q.question_translations.create(:locale => 'ka', :name => 'Bus stop signs are easy to read')
QuestionPairing.create(:id => 56, :question_category_id => qc.id, :question_id => q.id, :sort_order => 6)


v = Venue.create(:id => 44, :venue_category_id => vc.id, :sort_order => 4)
v.venue_translations.create(:locale => 'en', :name => 'Metro')
v.venue_translations.create(:locale => 'ka', :name => 'Metro')
v = Venue.create(:id => 45, :venue_category_id => vc.id, :sort_order => 5)
v.venue_translations.create(:locale => 'en', :name => 'Train Station')
v.venue_translations.create(:locale => 'ka', :name => 'Train Station')
v = Venue.create(:id => 46, :venue_category_id => vc.id, :sort_order => 6)
v.venue_translations.create(:locale => 'en', :name => 'Airport')
v.venue_translations.create(:locale => 'ka', :name => 'Airport')



puts "done venue records"
=end
