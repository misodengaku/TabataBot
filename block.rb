require 'yaml'
require 'twitter'

settings = YAML::load(open("./tabata.conf"))
nglists = open("nguser.txt").read.split("\n")
puts "[#{Time.now}]: NGuser loaded: #{nglists.length} users."
Twitter.configure do |config|
	config.consumer_key         = settings["consumer_key"]
    config.consumer_secret      = settings["consumer_secret"]
    config.oauth_token          = settings["oauth_token"]
    config.oauth_token_secret   = settings["oauth_token_secret"]
end                                                                                
nglists.each { |id|
	Twitter.block(id)
	puts "#{id} blocked."
}
puts "complete."
