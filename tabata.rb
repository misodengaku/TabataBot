<<<<<<< HEAD
#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'daemon_spawn'
require 'tweetstream'
require 'time'
require 'sqlite3'
require 'yaml'
include SQLite3

class TabataDaemon < DaemonSpawn::Base
	@filter = nil
	@stream = nil
	
	def start(args)
		#puts("\n\n")
		#ToDo: あとでLFになおす
		nglists = open("nguser.txt").read.split("\r\n")
		p nglists
		#return
		
		begin
			settings = YAML::load(open("./tabata.conf"))
		rescue
			puts "[ERROR] config file load failed."
		end
		db = Database.new("./tabata.db")
		#update.execute(count, screen_name)
		update = db.prepare('UPDATE users SET count=?,recent=? WHERE screen_name=?')
		# insert.execute(screen_name, created_at)
		insert = db.prepare('INSERT INTO users VALUES(?, 1, ?)')


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
      	begin
			@filter = Thread.new{			
				client.track("田端でバタバタ") do |status|
					if status.retweeted_status.nil? & nglists.index(status.user.screen_name) == nil then #フィルタ
						puts "new tweet catched"
						Twitter.favorite(status.id)
					
						i = db.get_first_value("SELECT COUNT(*) FROM users WHERE screen_name='#{status.user.screen_name}'")
						if i != 0 then
							puts "update"
						
						count =	db.get_first_value("SELECT count FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i
							recent = db.get_first_value("SELECT recent FROM users WHERE screen_name = \"#{status.user.screen_name}\"")
							#p (status.created_at-recent).to_time.to_i
							count = count + 1
						
							begin
								Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に田端でバタバタしました。通算#{count}回目です。")
								rescue => exc
									puts "[!] Twitter Error"
								p exc
							end
						
							begin
								update.execute(count, status.created_at.to_s, status.user.screen_name)
							rescue => exc
								puts "[!] SQL Error"
								p exc
							end
							puts("updated: #{status.user.screen_name}")
						
						else
							puts "insert"
						
							begin
								Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に初めて田端でバタバタしました。")
							rescue => exc
								puts "[!] Twitter Error"
								p exc
							end
						
							begin
								insert.execute(status.user.screen_name, status.created_at.to_s)
							rescue => exc
								puts "[!] SQL Error"
								p exc
							end
						
							puts "new user: #{status.user.screen_name}"
						end
					end

					sleep 0.01
            	end
			}
        rescue => exc
			puts "[ERROR] UserStream Thread exception:#{exc}"
          	retry
        end

      	begin
			@stream = Thread.new{
				client.userstream do |status|
	          		puts "stream catched"
					if status.user.screen_name == "misodengaku" and status.text.include?("生存確認") then
						Twitter.favorite(status.id)
						Twitter.update("@misodengaku 田端botは正常に稼働しています。")
					end
					sleep 0.01
				end
			}
        rescue => exc
			puts "[ERROR] UserStream Thread exception:#{exc}"
          	retry
        end
		
		puts "thread start"
		@stream.run
		@filter.join
	end
	
	def stop
		if @filter then
			Thread::kill(@filter)
		end
		if @stream then
			Thread::kill(@stream)
		end
		
		puts "Tabata_bot is stoped."
	end
end

TabataDaemon.spawn!({
	:working_dir => Dir::getwd, # これだけ必須オプション
	:pid_file => './tabata.pid',
	:log_file => './tabata.log',
	:sync_log => true,
	:singleton => true # これを指定すると多重起動しない
})
=======
#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'daemon_spawn'
require 'tweetstream'
require 'time'
require 'sqlite3'
require 'yaml'
include SQLite3

class TabataDaemon < DaemonSpawn::Base
	@filter = nil
	@stream = nil
	
	def start(args)
		puts("\n\n")
		nglists = open("nglist.txt").split("\n")
		p nglists
		return
		
		
		settings = YAML::load(open("./tabata.conf"))
		db = Database.new("./tabata.db")
		#update.execute(count, screen_name)
		update = db.prepare('UPDATE users SET count=?,recent=? WHERE screen_name=?')
		# insert.execute(screen_name, created_at)
		insert = db.prepare('INSERT INTO users VALUES(?, 1, ?)')


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
		@filter = Thread.new{
			
			client.track("田端でバタバタ") do |status|
				if status.retweeted_status.nil? then #RT弾き
					puts "new tweet catched"
					Twitter.favorite(status.id)
					
					i = db.get_first_value("SELECT COUNT(*) FROM users WHERE screen_name='#{status.user.screen_name}'")
					if i != 0 then
						puts "update"
					
						count =	db.get_first_value("SELECT count FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i
						recent = db.get_first_value("SELECT recent FROM users WHERE screen_name = \"#{status.user.screen_name}\"")
						#p (status.created_at-recent).to_time.to_i
						count = count + 1
						
						begin
							Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に田端でバタバタしました。通算#{count}回目です。")
						rescue => exc
							puts "[!] Twitter Error"
							p exc
						end
						
						begin
							update.execute(count, status.created_at.to_s, status.user.screen_name)
						rescue => exc
							puts "[!] SQL Error"
							p exc
						end
						puts("updated: #{status.user.screen_name}")
						
					else
						puts "insert"
						
						begin
							Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に初めて田端でバタバタしました。")
						rescue => exc
							puts "[!] Twitter Error"
							p exc
						end
						
						begin
							insert.execute(status.user.screen_name, status.created_at.to_s)
						rescue => exc
							puts "[!] SQL Error"
							p exc
						end
						
						puts "new user: #{status.user.screen_name}"
					end
				end

				sleep 0.01
			end
		}
		
		@stream = Thread.new{
			client.userstream do |status|
				if status.user.screen_name == "misodengaku" and status.text.include?("生存確認") then
					Twitter.favorite(status.id)
					Twitter.update("@misodengaku 田端botは正常に稼働しています。")
				end
				sleep 0.01
			end
		}
		
		puts "thread start"
		@stream.run
		@filter.join
	end
	
	def stop
		Thread::kill(@filter)
		Thread::kill(@stream)
		
		puts "Tabata_bot is stoped."
	end
end

TabataDaemon.spawn!({
	:working_dir => Dir::getwd, # これだけ必須オプション
	:pid_file => './tabata.pid',
	:log_file => './tabata.log',
	:sync_log => true,
	:singleton => true # これを指定すると多重起動しない
})
>>>>>>> origin/master
