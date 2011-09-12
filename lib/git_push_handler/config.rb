module PushHandler
	class Config
		attr_accessor :repo
		attr_accessor :commit_url

		def initialize
			@repo = Hash.new('')
			@commit_url = ''
		end
	end
end