#!/usr/bin/ruby

require 'socket'
require 'digest/md5'

class Irc
	attr_accessor :host, :port, :chans, :handle, :sockfd, :threads, :match, :line

	def initialize( host, port, chans, handle )
		@host = host
		@port = port
		@chans = chans
		@handle = handle
		@@threads = []
		@@match = @sockfd = @@line = nil
	end

	def connect

    begin
			p "[?] Trying #{@host}"

			@sockfd = TCPSocket.open( @host, @port )
			@sockfd.setsockopt( Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true )


			@sockfd.puts( "NICK #{@handle}" )
			@sockfd.puts( "USER #{@handle} 8 * :#{@handle}" )
		
			@chans.each do |i|
				@sockfd.puts( "JOIN #{i}" )
			end

			task( @sockfd )

		rescue NameError => boom
			p "Error! boom: #{boom}"
			p "Skipping #{@host}"

			@sockfd.close
		end
	end

	def task( sfd )
		while @@line = sfd.gets
    		Thread.new do 
				parse
    		end
		end
	end

	def parse
        
        p "Weee gOT A LINE!! " << @@line


        case @@line
            when /PING :(.+)/i
				@sockfd.puts("PONG :#{$1}" )

			when /^:(.*?)!(.*?)@(.*?)\s(.*?)\s([^\s]+)\s:([^\r\n]+)/
				@@match = [ $1, $2, $3, $4, $5, $6 ]

                @@match.each do |m|
                    p "Match: #{m}"
                end

				respond
		end
	end

	def respond
        @@nick = @@match[0]
        @@user = @@match[1]
        @@host = @@match[2]
        @@action = @@match[4]
        @@target = @@match[5]
        @@line = @@match[6].split("\s")

        
        @@line.each do |l|
            p "Got: #{l}"    
#		@sockfd.puts("#{resp}")
    	end

    end
end
  

class User
    attr_accessor :nick, :user, :host, :common_channels

    def initialize( nick, user, host )
        @@nick = nick
        @@user = user
        @@host = host
    end

end




#irc = Irc.new("irc.2600.net", 6667, [ "###lolbutts", "###lolqwut" ], "qwarzaard" )
irc = Irc.new("irc.freenode.net", 6667, [ "###lolbutts", "###lolqwut" ], "qwarzaard" )

irc.connect()

