puts "------------------------------------------"
puts "---Correspondence Generator (CorGe) v0.0.2"
puts "------------------------------------------"
require 'yaml'
require 'csv'
require 'mail'
require 'highline/import'

#------------Functions----------
def ui_main
	puts "\n------------Manage Messages------------"
	puts "1. Generate Messages"
	puts "2. Send Messages"
	puts "3. List Messages"
	puts "4. List Sent Messages"
	puts "5. Read Message"
	puts "6. Mark Message As Sent"
	puts "7. Delete Sent Messages"
	puts "8. Exit"
	input = ask("Choose An Option: ")

	if input == "1"
		generate_from_csv(@config[:generated],@config[:csv],@config[:template])
		ui_main
	elsif input == "2"
		if @config[:send_mail]
			email_options @config[:mail_options]
			send_generated_messages
		else
			puts "\nsend_mail is disabled, adjust the config file to send messages."
		end
		ui_main
	elsif input == "3"
		list_messages ".corge"
		ui_main
	elsif input == "4"
		list_messages ".sent"
		ui_main
	elsif input == "5"
		filenames = ask("\nEnter Message File Path(s): ")
		read_message filenames.split(" ")
		ui_main
	elsif input == "6"
		filenames = ask("\nEnter Message File Path(s): ")
		mark_as_sent filenames.split(" ")
		ui_main
	elsif input == "7"
		verify = ask("\nAre you sure? y/n")
		if verify == "y"
			delete_sent_messages
		end
		ui_main
	elsif input == "8"
		puts "You're skilled and awesome! Have a good day!"
	else
		puts "\nUnrecognized Input."
		ui_main
	end
end

def read_configs
	@config = YAML.load_file("config")
end

def email_options mail_options
	if @config[:prompt_credentials]
		@config[:mail_options][:user_name] = ask("\nEmail Username: ")
		@config[:mail_options][:password] = ask("Email Password: ") { |q| q.echo = "*" }
	end
	Mail.defaults do
		delivery_method :smtp, mail_options
	end
end

def generate_from_csv output_path, csv_path, template_path
	titles = []
	CSV.foreach(csv_path) do |row|
		if $. == 1
			titles = row
		else
			template = File.open(template_path, 'r')
			output = File.open(output_path+@config[:generated_filename_prefix]+row[0].gsub(/ /, "_")+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge", 'w')
			
			#special fields and attachents
			row.each_with_index do |r,i|
				if titles[i].downcase == "email"
					output.puts ":to_email: "+row[i].to_s
				end
				if titles[i].downcase == "attachments"
					output.puts ":attachments: "
					row[i].to_s.split('|').each do |attach|
						output.puts "    - "+attach.to_s
					end
				end
				if titles[i].downcase == "subject"
					output.puts ":subject: "+row[i].to_s
				end
			end

			#body
			output.print ":body: \""
			template.each_line do |line|
				replace = {}
				row.each_with_index do |r, i|
					if r.to_s.strip.empty?
						replace['{'+titles[i].to_s+'}'] = titles[i].to_s
					else
						replace['{'+titles[i].to_s+'}'] = r
					end
				end
				output.print(line.gsub(/(\{.+?\})/, replace)+"\n")
			end
			output.print "\""
			print "generated "+output_path+@config[:generated_filename_prefix]+row[0].gsub(/ /, "_")+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge"+".\n"
			output.close
			template.close
		end
	end
end

def list_messages extension
	puts "\n"
	files_exist = false
	Dir.glob(@config[:generated]+'*'+extension) do |correspondence|
		puts correspondence
		files_exist = true
	end
	if !files_exist
		puts "No Messages Found With "+extension+" file extension."
	end
end

def read_message files
	files.each do |file|
		puts "\n------------"+file+"-------------"
		message = YAML.load_file(file)
		if message.empty?
			puts "There was an error displaying "+file
		else
			puts "To:"+(message[:to_email].to_s || @config[:to_email].to_s)
			puts "From: "+(message[:from_email].to_s || @config[:from_email].to_s)
			puts 'Subject: '+(message[:subject].to_s || @config[:subject].to_s)
			puts "Body: "+(message[:body].to_s || @config[:body].to_s)
			if message[:attachments]
				puts "Attachments: "+message[:attachments].join(",")
			end
		end
	end
end

def send_generated_messages
	Dir.glob(@config[:generated]+'*.corge') do |correspondence|
		message = YAML.load_file(correspondence)
		
		mail = Mail.new
		mail.from = @config[:from_email]
		mail.to = message[:to_email] || @config[:to_email]
		mail.subject = message[:subject] || @config[:subject]
		mail.body = message[:body] || @config[:body]
		message[:attachments].to_a.each do |att|
			mail.add_file(att)
		end
		mail.deliver!
		File.rename(correspondence, correspondence+".sent")
	end
end

def mark_as_sent files
	files.to_a.each do |file|
		if file.include? ".corge"
			if file.include? ".sent"
				puts "file "+file+" is already marked as sent"
			else
				File.rename(file, file+".sent")
				puts file+" Marked as sent."
			end
		else
			puts file+" is not a valid .corge file"
		end
	end
end

def delete_sent_messages
	Dir.glob(@config[:generated]+'*.sent') do |correspondence|
		puts "Deleting "+correspondence
		File.delete(correspondence)
	end
end

#------------Init----------
read_configs
ui_main