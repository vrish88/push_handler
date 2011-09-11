require 'push_handler'

describe PushHandler do
	include PushHandler
	describe '.new_push' do
		# repo info
		let(:url)   { 'http://example.com/repo.git' }
		let(:name)  { 'Just a test repo' }
		let(:owner) { {'name' => 'Joe Schmoe', 'email' => 'schmoe@example.com'} }

		let(:old_commit_hash) { 'aa453216d1b3e49e7f6f98441fa56946ddcd6a20' }
		let(:new_commit_hash) { '68f7abf4e6f922807889f52bc043ecd31b79f814' }
		let(:ref_name)        { 'refs/heads/master' }

		let(:result) { PushHandler.new_push(old_commit_hash, new_commit_hash, ref_name) }

		before :all do
			PushHandler.configure do |config|
				config.url = url
				config.name = name
				config.owner = owner
			end
		end

		context 'should return a payload with the following' do
			subject { result }
			specify 'after should be the new commit hash' do
				should include_hash('after' => new_commit_hash)
			end

			specify 'ref should be the ref name' do
				should include_hash('ref' => ref_name)
			end

			specify 'before should be the old commit hash' do
				should include_hash('before' => old_commit_hash)
			end

			# context 'created'
			# context 'deleted'
			# context 'forced'

			context 'repository info is specified in a config call' do
				subject { result['repository'] }

				specify 'should load the repo name' do
					should include_hash('name' => name)
				end

				specify 'should load the repo url' do
					should include_hash('url' => url)
				end

				context "the owner's" do
					subject { result['repository']['owner']}
					specify "name" do
						should include_hash('name' => owner['name'])
					end
					specify "email" do
						should include_hash('email' => owner['email'])
					end
				end
			end

			context 'pusher' do
				it 'should be the author of the latest commit'

				it 'should be the name of that author'
			end

			context 'commits' do
				context 'each commit should have the following info' do
					subject { result['commits'] }

					it "should have distinct marked true (distinct to the branch? I'm not sure)"
					context 'removed' do
						it "should return an empty array if no files were removed"
						it "should return an array of file names if any were removed"
					end
					context 'added' do
						it "should return an empty array if no files were added"
						it "should return an array of file names if any were added"
					end
					context 'modified' do
						it "should return an empty array if no files were modified"
						it "should return an array of file names if any were modified"
					end
					it "should have the commit message in 'message'"
					it "should have the timestamp in 'timestamp'"
					it "should have the url in 'url'"
					context 'author should be a hash with the keys' do
						specify 'name'
						specify 'email'
					end
					it "should specify the commit id in 'id'"
				end
			end
		end
	end
end

RSpec::Matchers.define :include_hash do |expected|

	match do |actual|
		expected.keys.all?{|key| actual.has_key?(key)} &&
			actual.slice(*expected.keys) == expected
	end

end

# port over Rails' Hash#slice method
class Hash
	def slice(*keys)
		keys = keys.map! { |key| convert_key(key) } if respond_to?(:convert_key)
		hash = self.class.new
		keys.each { |k| hash[k] = self[k] if has_key?(k) }
		hash
	end
end