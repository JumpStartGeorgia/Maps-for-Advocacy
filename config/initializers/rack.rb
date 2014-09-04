# due to evaluation form having a lot of questions with ability to load multiple images,
# the default key space limit is too small
if Rack::Utils.respond_to?("key_space_limit=")
  Rack::Utils.key_space_limit = 262144 
end
