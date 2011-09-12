module PushHandler
	class Config
		attr_accessor :repo
		attr_accessor :commit_url
		attr_accessor :services

		def initialize
			@repo = Hash.new('')
			@services = Hash.new()
			@commit_url = ''
		end
	end
end