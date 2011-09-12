module PushHandler
	class Config
		attr_accessor :url
		attr_accessor :name
		attr_accessor :owner
		attr_accessor :working_dir

		def initialize
			@url = ''
			@name = ''
			@owner = {}
		end
	end
end