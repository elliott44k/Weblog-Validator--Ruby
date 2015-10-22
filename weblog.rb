def bytes(file)
	total = 0
	while line = file.gets do

		if line == "\n"
			next
		end

		line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)

		if $7 == "-" then
			next
		end

		total += $7.to_i
	end

	if total / 1073741824 >= 1 then
		total = total / 1073741824
		unit = "GB"
	elsif total / 1048576 >= 1 then
		total = total / 1048576
		unit = "MB"
	elsif total / 1024 >= 1 then
		total = total / 1024
		unit = "KB"
	else
		unit = "bytes"
	end

	puts "#{total} #{unit}"

end

def popularity(file)
	array = Hash.new
	array.default = 0
	while line = file.gets do
		line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)
		array[$5] = array[$5] + 1
	end
	sorted = array.sort_by{|k,v| v}.reverse
	if sorted.count < 10
		for i in 0...sorted.count
			puts "#{sorted[i][1]} #{sorted[i][0]}"
		end
	else
		for i in 0...10
			puts "#{sorted[i][1]} #{sorted[i][0]}"
		end
	end

end

def requests(file)

	array_bytes = Hash.new
	array_count = Hash.new
	array_bytes.default = 0
	array_count.default = 0

	while line = file.gets do
		line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)
		array_bytes[$1] = array_bytes[$1] + $7.to_i
		array_count[$1] = array_count[$1] + 1
	end

	keys = array_bytes.keys
	keys.sort_by!{|ip| ip.split('.').map{ |octet| octet.to_i} }

	keys.each{|key| puts "#{key} #{array_count[key]} #{array_bytes[key]}"}

end

def time(file)

	arr = Array.new(24, 0)
	while line = file.gets do
		if line == "\n"
			next
		end

		array = line.split(/\.| /)

		array[6].scan(/\[(\d+)\/([a-zA-Z]+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)/)
		arr[$4.to_i] += 1
	end

	for i in 0...24
		if i < 10 then
			puts "0#{i} #{arr[i]}"
		else
			puts "#{i} #{arr[i]}"
		end
	end
end

def validate(file)
	# read line 
	while line = file.gets do

		if line == "\n"
			next
		end

		array = line.scan(/"(.*)"/)
		command = array[0]
		if command.to_s.include? '"' then
			while command[0].include? '"' do
				location = command[0].index('"')
				if command[0][location.to_i-1] != "\\" then
					invalid_line
					return
				end
				command[0].slice!(location)
				command[0].slice!(location.to_i-1)
			end
		end

		array = line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)
		
		# check if empty line
		if array.count == 0 then
			invalid_line
			return
		end

		# check if valid line
		if array[0].count != 7 then
			invalid_line
			return
		end

		# check line contents

		# check valid ip address
		array = line.split(/\.| /)
		for i in 0..4
			if array[i].to_i < 0 || array[i].to_i > 255 then
				invalid_line
				return
			end
		end

		# check hyphen
		if array[4] != "-" then
			invalid_line
			return
		end

		# check username or hyphen
		if array[5] !~ /^(\w|\-)+$/ then
			invalid_line
			return
		end
		
		# check timestamp
		array[6].scan(/\[(\d+)\/([a-zA-Z]+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)/)
		
		# day
		if $1.to_i < 1 || $1.to_i > 31 then
			invalid_line
			return
		end

		# month
		if $2 !~ /(?i)(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)/ then
			invalid_line
			return
		end

		# year
		array[6].scan(/\[(\d+)\/([a-zA-Z]+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)/)

		if $3 !~ /\b\d{4}\b/ then
			invalid_line
			return
		end

		# hour
		array[6].scan(/\[(\d+)\/([a-zA-Z]+)\/(\d+)\:(\d+)\:(\d+)\:(\d+)/)

		if $4.to_i < 10 && $4.to_i >= 0 then
			if $4.length < 2 then
				invalid_line
				return
			end
		end

		if $4.to_i > 23 || $4.to_i < 0 then
			invalid_line
			return
		end

		# minute
		if $5.to_i < 10 && $5.to_i >= 0 then
			if $5.length < 2 then
				invalid_line
				return
			end
		end

		if $5.to_i > 59 || $5.to_i < 0 then
			invalid_line
			return
		end

		# second
		if $6.to_i < 10 && $6.to_i >= 0 then
			if $6.length < 2 then
				invalid_line
				return
			end
		end

		if $6.to_i > 59 || $6.to_i < 0 then
			invalid_line
			return
		end

		# time zone
		if array[7] !~ /\-0400\]/ then
			invalid_line
			return
		end

		# check command
		array = line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)
		if $5 !~ (/"([^"]*)"/) then
			invalid_line
			return
		end

		if $5 =~ (/"(")"/) then
		end

		# check status code
		array = line.scan(/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}) (\-) (.+) (\[.+\]) (".*") (\d+) (.*)\n/)
		if $6.to_i < 0 then
			invalid_line
			return
		end

		# check bytes sent
		bytes = $7

		if bytes.to_i < 0 then
			invalid_line
			return
		end

		if bytes =~ /\D+/ then
			if bytes != "-" then
				invalid_line
				return
			end
			next
		end

	end
	
	puts "yes\n"
	return
end

def invalid_line
	puts "no\n"
end

#-----------------------------------------------------------
# EXECUTABLE CODE
#-----------------------------------------------------------

command = ARGV[0]
file = ARGV[1]
use_file = open(file)

#----------------------------------
# perform command

case command

	when "bytes"
		bytes(use_file)
		
	when "popularity"
		popularity(use_file)

	when "requests"
		requests(use_file)
		
	when "time"
		time(use_file)
	
	when "validate"
		validate(use_file)

end
