require 'push_handler'

describe PushHandler do
	include PushHandler
	describe '.new_push' do
		# repo info
		let(:url)   { 'http://example.com/repo.git' }
		let(:name)  { 'Just a test repo' }
		let(:owner) { {'name' => 'Joe Schmoe', 'email' => 'schmoe@example.com'} }
		let(:working_dir) { File.expand_path(File.dirname(__FILE__) + '/example_git_repo/') }
		let(:commit_url)  { 'http://example.com/master/commit?id=%s'}

		let(:old_commit_hash) { '1afa4eba68c883738af4536f7e04d978964bb523' }
		let(:new_commit_hash) { '4e1b47e950a2f5d6afa6744fa92f3fce5d606e1b' }
		let(:ref_name)        { 'refs/heads/master' }

		let!(:result) do
			PushHandler.new_push(old_commit_hash, new_commit_hash, ref_name)
		end

		before :all do
			PushHandler.configure do |config|
				config.url = url
				config.name = name
				config.owner = owner
				config.working_dir = working_dir
				config.commit_url = commit_url
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

				subject { result['pusher'] }

				it 'should be the author of the latest commit' do
					should include_hash('name' => 'Joe Schmoe')
				end
			end

			context 'commits' do
				context 'each commit should have the following info' do
					subject { result['commits'].first }

					it "should have distinct marked true (distinct to the branch? I'm not sure)" do
						should include_hash('distinct' => true)
					end
					context 'removed' do
						it "should return an array of file that were removed (if any)" do
							should include_hash('removed' => [])
						end
					end
					context 'added' do
						it "should return an array of file that were added (if any)" do
							should include_hash('added' => [])
						end
					end
					context 'modified' do
						it "should return an array of file that were modified (if any)" do
							should include_hash('modified' => ['README'])
						end
					end
					it "should have the commit message in 'message'" do
						should include_hash('message' => 'add some more')
					end
					it "should have the timestamp in 'timestamp'" do
						should include_hash('timestamp' => '2011-06-20T01:13:11-07:00')
					end
					it "should have the url in 'url'" do
						should include_hash('url' => 'http://example.com/master/commit?id=f7e495a93758c74589acc28f8bc0893e4c89e7e8')
					end
					context 'author should be a hash with the keys' do
						subject { result['commits'].first['author'] }
						specify 'name' do
							should include_hash('name' => 'Joe Schmoe')
						end
						specify 'email' do
							should include_hash('email' => 'schmoe@example.com')
						end
					end
					it "should specify the commit id in 'id'" do
						should include_hash('id' => 'f7e495a93758c74589acc28f8bc0893e4c89e7e8')
					end
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