#------------------------------------------
#---Correspondence Generator (CorGe) v0.0.1
#------------------------------------------
require 'yaml'
require 'csv'
require 'mail'

#------------Functions----------
=begin
def test
	output_file = "test.txt"
	template_file = "templates/template_test.rb"

	template = File.open(template_file, 'r')
	output = File.open(output_file, 'w')

	template.each_line do |line|
		getval = {}
		match = line.scan(/(\{.+?\})/)
		match.each do |m|
			puts m[0]
			getval[m[0]] = gets.chomp
		end
		output.puts(line.gsub(/(\{.+?\})/, getval))
		print line.gsub(/(\{.+?\})/, getval)
	end
	template.close
	output.close
end
=end

def read_config
	@config = YAML.load_file("config.yaml")
end

def email_options mail_options
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
			output = File.open(output_path+"correspondence_"+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge", 'w')
			template.each_line do |line|
				replace = {}
				row.each_with_index do |r, i|
					if r.to_s.strip.empty?
						replace['{'+titles[i].to_s+'}'] = titles[i].to_s
					else
						replace['{'+titles[i].to_s+'}'] = r
					end
				end
				output.puts(line.gsub(/(\{.+?\})/, replace))
			end
			print "generated "+output_path+"correspondence_"+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge"+".\n"
			output.close
			template.close
		end
	end
end

def send_generated_messages custom_config
	Dir.glob(@config[:generated]+'*.corge') do |correspondence|
		mail = Mail.new
		mail.from = @config[:from_email]
		mail.to = @config[:to_email]
		mail.subject = @config[:subject]
		mail.body = File.read(correspondence)
		mail.deliver!
	end
end

#------------Init----------
#test
read_config
email_options @config[:mail_options]
generate_from_csv(@config[:generated],@config[:csv],@config[:template])
send_generated_messages nil