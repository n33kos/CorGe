#------------------------------------------
#---Correspondence Generator (CorGe) v0.0.2
#------------------------------------------
require 'yaml'
require 'csv'
require 'mail'

#------------Functions----------
def read_configs
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
			output = File.open(output_path+@config[:generated_filename_prefix]+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge", 'w')
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
			print "generated "+output_path+@config[:generated_filename_prefix]+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".corge"+".\n"
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
		File.rename(correspondence, correspondence+".sent")
	end
end

#------------Init----------
read_configs
email_options @config[:mail_options]
generate_from_csv(@config[:generated],@config[:csv],@config[:template])
if @config[:send_mail]
	send_generated_messages nil
end