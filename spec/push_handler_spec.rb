require 'push_handler'

describe PushHandler do
	include PushHandler

	let(:repo)   { {
		'url' => 'http://example.com/repo.git',
		'name' => 'Just a test repo',
		'owner' => {
			'name' => 'Joe Schmoe', 
			'email' => 'schmoe@example.com'
		},
		'working_dir' => File.expand_path(File.dirname(__FILE__) + '/example_git_repo/'),
		'is_bare' => false
	} }
	let(:urls)      { {
		'branch' => 'http://example.com/%s',
		'commit' => 'http://example.com/master/commit?id=%s'
	} }

	let(:old_commit_hash) { '1afa4eba68c883738af4536f7e04d978964bb523' }
	let(:new_commit_hash) { '4e1b47e950a2f5d6afa6744fa92f3fce5d606e1b' }
	let(:ref_name)        { 'refs/heads/master' }

	before :all do
		PushHandler.configure do |config|
			config.repo = repo
			config.urls['commit'] = urls['commit']
			config.urls['branch'] = urls['branch']
			config.services['url'] = 'http://localhost:8080'
		end
	end

	describe '.send_to_services' do
		context 'for each service configuration provided' do
			it 'should send a request to that corresponding url'

			it 'should send along the corresponding payload'
		end
	end

	describe '.construct_payload' do
		# repo info
		let!(:result) do
			PushHandler.construct_payload(old_commit_hash, new_commit_hash, ref_name)
		end

		context 'should return a payload with the following' do
			subject { result }
			specify 'after should be the new commit hash' do
				should include_hash('after' => new_commit_hash)
			end

			specify 'ref should be the ref name' do
				should include_hash('ref' => ref_name)
			end

			# NOT IN THE GITHUB SPECIFICATION
			specify 'branch_url should have the branch name put into the url["branch"] string' do
				should include_hash('branch_url' => urls['branch'] % 'master')
			end

			specify 'before should be the old commit hash' do
				should include_hash('before' => old_commit_hash)
			end

			context 'repository info is specified in a config call' do
				subject { result['repository'] }

				specify 'should load the repo name' do
					should include_hash('name' => repo['name'])
				end

				specify 'should load the repo url' do
					should include_hash('url' => repo['url'])
				end

				context "the owner's" do
					subject { result['repository']['owner']}
					specify "name" do
						should include_hash('name' => repo['owner']['name'])
					end
					specify "email" do
						should include_hash('email' => repo['owner']['email'])
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
		actual.fetch(expected.keys.first) == expected.values.first
	end
end