module PushHandler
	class Config
		attr_accessor :repo
		attr_accessor :urls
		attr_accessor :commit_url # DEPRECATED: please use urls['commit'] instead
		attr_accessor :services

		def initialize
			@repo = Hash.new('')
			@services = Hash.new()
			@commit_url = ''
			@urls = Hash.new('')
		end
	end
end