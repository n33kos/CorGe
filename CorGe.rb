#------------------------------------------
#---Correspondence Generator (CorGe) v0.0.1
#------------------------------------------

#------------Functions----------
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
end

#------------Init----------
test