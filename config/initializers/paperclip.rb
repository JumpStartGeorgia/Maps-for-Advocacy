# if using nested_form to upload files and want all files for a record under one folder
# replace 'xxx_id' with the name of the object parameter name that you want to use as the folder name
Paperclip.interpolates('place_id') do |attachment, style|
  attachment.instance.place_id
end

Paperclip.interpolates('place_evaluation_id') do |attachment, style|
  attachment.instance.place_evaluation_id
end

