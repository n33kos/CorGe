#------------------------------------------
#---Correspondence Generator (CorGe) v0.0.1
#------------------------------------------

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
	require 'yaml'
	@config = YAML.load_file("config.yaml")
end

def generate_from_csv output_path, csv_path, template_path
	require 'csv'
	titles = []
	CSV.foreach(csv_path) do |row|
		if $. == 1
			titles = row
		else
			template = File.open(template_path, 'r')
			output = File.open(output_path+"correspondence_"+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S'), 'w')
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
			print "generated "+output_path+"correspondence_"+row[0]+"_"+Time.now.strftime('%Y-%m-%d_%H%M%S')+".\n"
			output.close
			template.close
		end
	end
end

def send_generate_messages
end

#------------Init----------
#test
read_config
puts @config
generate_from_csv('generated/',@config['csv'],@config['template'])