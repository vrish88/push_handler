module PushHandler
	def self.new_push(old_commit, new_commit, ref_name)
		{
			'after' => new_commit,
			'before' => old_commit,
			'ref' => ref_name
		}
	end
end