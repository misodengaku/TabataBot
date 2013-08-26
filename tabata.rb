#!/usr/bin/env ruby
#-*- coding: utf-8 -*-

require 'daemon_spawn'
require 'tweetstream'
require 'time'
require 'sqlite3'
require 'yaml'
include SQLite3

#検索するワード（なんかよくわかんないけどダメでした）
#TRACKWORD = "田端でバタバタ"

class TabataDaemon < DaemonSpawn::Base
	@filter = nil
	@stream = nil
	@flFlag = false
	
	def start(args)
		puts("\n\n") #ログの区切り
		
		#設定ファイルロード
		begin
			settings = YAML::load(open("./tabata.conf"))
		rescue
			puts "[#{Time.now}]: [ERROR] config file load failed."
		end
		puts "[#{Time.now}]: config file loaded."
		
		#NGユーザーリストロード
		nglists = open("nguser.txt").read.split("\n")
		puts "[#{Time.now}]: NGuser loaded: #{nglists.length} users."
		
		#SQLiteの準備
		db = Database.new("./tabata.db")
		update = db.prepare('UPDATE users SET count=?,recent=? WHERE screen_name=?')
		insert = db.prepare('INSERT INTO users VALUES(?, 1, ?)')
		delete = db.prepare('DELETE FROM users WHERE screen_name=?')
		nglists.each do |name|
			delete.execute(name)
		end
		puts "[#{Time.now}]: nguser remove complete."
		statUp = db.prepare('UPDATE stat SET count=? WHERE year=? and month=? and day=? and hour=?')
		statIns = db.prepare('INSERT INTO stat VALUES(?, ?, ?, ?, 1)')
		lastUp = db.prepare('UPDATE last SET screen_name=?')
		puts "[#{Time.now}]: database inited."

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
		
		if Twitter.user(settings["screen_name"]).nil? then
			puts "[#{Time.now}]: [ERROR] Twitter API Error"
		end

		Twitter.update_profile(:name => "田端でバタバタ")

		client = TweetStream::Client.new
		usClient = TweetStream::Client.new
		beforeTabaTime = Time.at(334334334) #適当

		begin
			@filter = Thread.new{
				puts "[#{Time.now}]: filter thread started."
				client.track("田端でバタバタ") do |status|
					interval = (status.created_at - beforeTabaTime).to_i
					puts "[#{Time.now}]: new tweet interval #{interval}"
					if status.retweeted_status.nil? && nglists.index(status.user.screen_name).nil? then # && status.source.index("twittbot.net").nil? then #フィルタ
						puts "[#{Time.now}]: accepted #{status.user.screen_name}"
						count = 0
						if db.get_first_value("SELECT COUNT(*) FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i != 0 then
							recent = Time.parse(db.get_first_value("SELECT recent FROM users WHERE screen_name = \"#{status.user.screen_name}\""))
							recent = (status.created_at - recent).to_i
							count = db.get_first_value("SELECT count FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i
						else
							recent = 60
						end
						if recent > 59 + count then
							begin
								Twitter.favorite(status.id)
								if @flFlag then
									Twitter.update_profile(:name => "田端でバタバタ")
									@flFlag = false
								end
							rescue => exc
								puts"[#{Time.now}]: [ERROR] Twitter Error (Fav Limit?)"
								if !@flFlag then
									Twitter.update_profile(:name => "田端でバタバタ (ふぁぼ規制中)")
									@flFlag = true
								end
								# p exc
							end
						
							i = db.get_first_value("SELECT COUNT(*) FROM users WHERE screen_name='#{status.user.screen_name}'")
							
							if i != 0 then
								puts "[#{Time.now}]: db update"
							
								# count =	db.get_first_value("SELECT count FROM users WHERE screen_name = \"#{status.user.screen_name}\"").to_i
								count = count + 1
								lastuser = db.get_first_value("SELECT screen_name FROM last").to_s
								if interval >= 85 + rand(10) and status.user.screen_name != lastuser then
									beforeTabaTime = status.created_at
									puts "[#{Time.now}]: twitter update"
									begin
										Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に田端でバタバタしました。通算#{count}回目です。")
										if @flFlag then
											Twitter.update_profile(:name => "田端でバタバタ")
											@flFlag = false
										end
									rescue => exc
										puts "[#{Time.now}]: [ERROR] Twitter Error"
										if !@flFlag then
											Twitter.update_profile(:name => "田端でバタバタ (ふぁぼ規制中)")
											@flFlag = true
										end
										# p exc
									end
									lastUp.execute(status.user.screen_name)
								else
									puts "[#{Time.now}]: postlimit evasion."
								end
							
								begin
									update.execute(count, status.created_at.to_s, status.user.screen_name)
								rescue => exc
									puts "[#{Time.now}]: [ERROR] SQL Error"
									p exc
								end
								puts "[#{Time.now}]: updated: #{status.user.screen_name}"
							
							else
								puts "[#{Time.now}]: insert"
								
								if interval >= 85 + rand(10) then
									beforeTabaTime = status.created_at
									begin
										Twitter.update("#{status.user.screen_name}さんが#{status.created_at.strftime("%H:%M:%S")}に初めて田端でバタバタしました。")
									rescue => exc
										puts "[#{Time.now}]: [ERROR] Twitter Error"
										p exc
									end
								else
									puts "[#{Time.now}]: postlimit evasion."
								end
							
								begin
									insert.execute(status.user.screen_name, status.created_at.to_s)
								rescue => exc
									puts "[#{Time.now}]: [ERROR] SQL Error"
									p exc
								end
							
								puts "[#{Time.now}]: new user: #{status.user.screen_name}"
							end
							
							i = db.get_first_value("SELECT COUNT(*) FROM stat WHERE year=#{status.created_at.year} and month=#{status.created_at.month} and day=#{status.created_at.day} and hour=#{status.created_at.hour}")
							if i <= 0 then
								statIns.execute(status.created_at.year, status.created_at.month, status.created_at.day, status.created_at.hour)
							else
								count = db.get_first_value("SELECT count FROM stat WHERE year=#{status.created_at.year} and month=#{status.created_at.month} and day=#{status.created_at.day} and hour=#{status.created_at.hour}").to_i
								count += 1
								#puts count
								statUp.execute(count, status.created_at.year, status.created_at.month, status.created_at.day, status.created_at.hour)
							end
						else
							puts "[#{Time.now}]: 1min limit: #{status.user.screen_name}"
						end
					elsif !nglists.index(status.user.screen_name).nil? then
						puts "[#{Time.now}]: NGUser blocked: #{status.user.screen_name}"
					else
						puts "[#{Time.now}]: retweet blocked"
					end
					sleep 0.01
				end
			}
		rescue => exc
			puts "[#{Time.now}]: [ERROR] UserStream Thread exception: #{exc}"
			retry
		end

		#begin
		#	@stream = Thread.new{
		#		puts "[#{Time.now}]: userstream thread started."
		#		usClient.userstream do |status|
		#			puts "[#{Time.now}]: stream catched"
		#			#if status.user.screen_name == "misodengaku" and status.text.include?("生存確認") then
		#			#	Twitter.favorite(status.id)
		#			#	Twitter.update("@misodengaku 田端botは正常に稼働しています。")
		#			#end
		#			sleep 0.01
		#		end
		#	}
		#rescue => exc
		#	puts "[#{Time.now}]: [ERROR] UserStream Thread exception:#{exc}"
		#	retry
		#end
		#
		puts "[#{Time.now}]: Tabata_bot is ready!"
		
		#begin
		
		#@stream.run
		@filter.join
		
		#rescue => exc
		#	puts "[#{Time.now}]: [ERROR] thread start failed."
		#	p exc
		#end
	end
	
	def stop
		puts "[#{Time.now}]: Tabata_bot is stoped."
		if @filter then
			Thread::kill(@filter)
		end
		if @stream then
			Thread::kill(@stream)
		end
		
	end
end

TabataDaemon.spawn!({
	:working_dir => Dir::getwd, # これだけ必須オプション
	:pid_file => './tabata.pid',
	:log_file => './tabata.log',
	:sync_log => true,
	:singleton => true # これを指定すると多重起動しない
})
