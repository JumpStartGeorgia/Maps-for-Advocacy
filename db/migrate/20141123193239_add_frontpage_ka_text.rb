# encoding: UTF-8
class AddFrontpageKaText < ActiveRecord::Migration
  def up
    PageTranslation.transaction do
      trans = PageTranslation.where(:page_id => 1, :locale => 'ka').first
      trans.content = "<p>Ability.ge არის საიტი, სადაც ადამიანები აგროვებენ და მოიძიებენ ინფორმაციას ხელმისაწვდომი გარემოს შესახებ საჯარო ადგილებში, როგორებიცაა შენობები, გადასასვლელები და სხვ. ამ საიტის გამოყენებით, შეგიძლიათ შეაფასოთ, რამდენად ხელმისაწვდომია გარემო თქვენ გარშემო და, ასევე, იპოვოთ თქვენთან ახლოს არსებული ხელმისაწვდომი ადგილები. დარეგისტრირდი, აღწერე და დაგვეხმარე, წავახალისოთ მთავრობა და კერძო სექტორი, გახადონ გარემო უფრო ხელმისაწვდომი თითოეული ჩვენგანისთვის.</p>"
      trans.save

      trans = PageTranslation.where(:page_id => 7, :locale => 'ka').first
      trans.title = 'როგორ უნდა განაცხადო გარემოს ხელმისაწვდომობასთან დაკავშირებული დარღვევის შესახებ?'
      trans.content = %q{<ol>
<li>უყურე <a href="/ka/training_videos">ვიდეოს</a> და <a href="/ka/what_is_accessibility">გაიგე ხელმისაწვდომი გარემოს შესახებ</a>.</li>
<li>აღწერე შენობები, პანდუსები, ბანკომატები და ქუჩები შენს სამეზობლოში.</li>
<li>Ability.ge-ზე მონიშნე ადგილი, რომლის შეფასებაც გინდა. შეგიძლია, ერთი და იმავე ადგილისთვის შეავსო რამდენიმე ტიპის შეფასების ფორმა.</li>
<li>უპასუხე შეკითხვებს და გამოგვიგზავნე შეფასება. ატვირთე ფოტოებიც!</li>
<li>ჩვენ ვმოქმედებთ! იმ დარღვევის შესახებ, რომელიც შენ აღმოაჩინე, ჩვენ ვაცნობებთ ბიზნესკომპანიებსა და სამთავრობო უწყებებს. ეს კი ჩვენს გარემოს უფრო ხელმისაწვდომს გახდის ყველასათვის.</li>
</ol>}
      trans.save
      
    end
  end

  def down
    PageTranslation.transaction do
      trans = PageTranslation.where(:page_id => 1, :locale => 'ka').first
      trans.content = PageTranslation.where(:page_id => 1, :locale => 'en').first.content
      trans.save

      trans = PageTranslation.where(:page_id => 7, :locale => 'ka').first
      trans.title = PageTranslation.where(:page_id => 7, :locale => 'en').first.title
      trans.content = PageTranslation.where(:page_id => 7, :locale => 'en').first.content
      trans.save
      
    end
  end
end
