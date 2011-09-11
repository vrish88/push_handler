require 'git_push_handler/config'

module PushHandler
	extend self
	attr_accessor :config

	# this configure method implementation is taken
	# from https://github.com/andrew/split/blob/master/lib/split.rb
	def self.configure
		self.config ||= Config.new
		yield(self.config)
	end

	def self.new_push(old_commit, new_commit, ref_name)
		hash_to_return = {
			'after' => new_commit,
			'before' => old_commit,
			'ref' => ref_name
		}

		hash_to_return['repository'] = {
			'url' => config.url,
			'name' => config.name,
			'owner' => config.owner
		}

		hash_to_return
	end
end