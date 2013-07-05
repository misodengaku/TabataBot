#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'daemon_spawn'
require 'tweetstream'
require 'time'
require 'sqlite3'
require 'yaml'
include SQLite3

class TabataDaemon < DaemonSpawn::Base
	db = nil
	def start(args)
		puts("\n\n")
		settings = YAML::load(open("./tabata.conf"))
		db = Database.new("./tabata.db")

		TweetStream.configure do |config|
			config.consumer_key			= settings["consumer_key"]
			config.consumer_secret		= settings["consumer_secret"]
			config.oauth_token			= settings["oauth_token"]
			config.oauth_token_secret	= settings["oauth_token_secret"]
			config.auth_method			= :oauth
		end

		Twitter.configure do |config|
			config.consumer_key			= settings["consumer_key"]
			config.consumer_secret		= settings["consumer_secret"]
			config.oauth_token			= settings["oauth_token"]
			config.oauth_token_secret	= settings["oauth_token_secret"]
		end

		client = TweetStream::Client.new

		puts "Tabata_bot is ready!"
		client.track("田端でバタバタ") do |status|
			Twitter.favorite(status.id)
			puts("faved.")
			#puts("SELECT count,recent FROM users WHERE screen_name='#{status.user.screen_name}'")
			i = db.get_first_value("SELECT COUNT(*) FROM users WHERE screen_name='#{status.user.screen_name}'")
			if i != 0 then
			count =	db.get_first_value("SELECT count FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i
			p count
				recent =	db.get_first_value("SELECT recent FROM users WHERE screen_name = \"#{status.user.screen_name}\"")
				p recent
			#p (status.created_at-recent).to_i
				count = count + 1
			puts("UPDATE users SET count=#{count} WHERE screen_name='#{status.user.screen_name}'")
				db.execute("UPDATE users SET count=#{count} WHERE screen_name='#{status.user.screen_name}'")
				Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に田端でバタバタしました。通算#{count}回目です。")
			else
			puts("new user")
			Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に初めて田端でバタバタしました。")
			puts("INSERT INTO users VALUES('#{status.user.screen_name}', 1, '#{status.created_at}')")
			db.execute("INSERT INTO users VALUES('#{status.user.screen_name}', 1, '#{status.created_at}')")
			end
			puts("posted.")
			#p result
			puts "#{status.user.screen_name}: update complete"
		end
		client.userstream do |status|
			if status.user.screen_name == "misodengaku" then
				Twitter.favorite(status.id)
				if status.text == "生存確認" then
					Twitter.update("@misodengaku 田端botは正常に稼働しています。")
				end
			end
		end
	end
	
	def stop
		db.close()
	end
end

TabataDaemon.spawn!({
	:working_dir => Dir::getwd, # これだけ必須オプション
	:pid_file => './hoge.pid',
	:log_file => './tabata.log',
	:sync_log => true,
	:singleton => true # これを指定すると多重起動しない
})
