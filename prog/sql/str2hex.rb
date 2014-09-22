#!/usr/bin/ruby
#
#convert string input into hex repesentation
#with '+' in hex if specified
require 'optparse'

opts = {}

opt_parse = OptionParser.new do |opt|

    opt.banner = "str2hex.rb input [OPTIONS]"
    opt.separator ""
    opt.separator "input : \"stringToConvert\" or via stdin"
    opt.on("-v","--verbose", "verbose output") do |v|
        opts[:v] = true
    end
    opt.on("-sep","--separator","join each char in the input string with a separator. Default is +. You can specify your own") do |s|
        if s && s.is_a?(String) && !s.empty?
            opts[:sep] = s 
        else
            opts[:sep] = "+"
        end
    end
    opt.on("-sql","--sql","SQL query format char(c1) + char(c2) ... ") do |sql|
        opts[:sql] = true
    end
end
opt_parse.parse!

unless ARGV[0] 
    $stderr.puts "No string specified" if opts[:v]
    abort
end

puts opts.inspect if opts[:v]
str = ARGV[0]
puts "Decoding #{str} ..." if opts[:v]
hex = []
str.each_byte { |b| hex << b.to_s(16) }
print "Hex : " if opts[:v]
sep = ""
if opts[:sep]
    opts[:sep].each_byte {|b| sep << b.to_s(16) }
end
if opts[:sql] 
    hex.map! { |c| print "char(#{c})" }
end

puts hex.join(sep)

