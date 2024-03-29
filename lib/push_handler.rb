require 'rubygems'
require 'grit'
require 'json'
require 'typhoeus'
require 'net/http'
require 'uri'

require File.expand_path(File.dirname(__FILE__) + '/push_handler/config')

module PushHandler
	extend self
	attr_accessor :config

	# this configure method implementation is taken
	# from https://github.com/andrew/split/blob/master/lib/split.rb
	def configure
		self.config ||= Config.new
		yield(self.config)
	end

	def send_to_services(old_commit, new_commit, ref_name)
		payload = construct_payload(old_commit, new_commit, ref_name)
		config.services['data'].each_pair do |service, data|
			Typhoeus::Request.post(
				config.services['url'] + '/' + service + '/push',
				:method => :post,
				:params => {
					'data' => data.to_json,
					'payload' => payload.to_json
				},
				:disable_ssl_peer_verification => true
			)
		end
	end

	def construct_payload(old_commit, new_commit, ref_name)
		hash_to_return = Hash.new({})
		hash_to_return = {
			'after' => new_commit,
			'before' => old_commit,
			'ref' => ref_name,
			'branch_url' => config.urls['branch'] % ref_name[/\/([^\/]+)$/, 1]
		}

		hash_to_return['repository'] = {
			'url' => config.repo['url'],
			'name' => config.repo['name'],
			'owner' => config.repo['owner']
		}
		repo = Grit::Repo.new(config.repo['working_dir'], :is_bare => config.repo['is_bare'])
		commits = Grit::Commit.find_all(
			repo,
			"#{old_commit}..#{new_commit}",
			:'no-merges' => true
		).reverse

		unless commits.empty?
			hash_to_return['pusher'] = {
				'name' => commits.first.author.name
			}
			hash_to_return['commits'] = commits.collect do |commit|
				Hash.new.tap do |commit_hash|
					commit_hash['distinct'] = true
					commit_hash['id'] = commit.sha
					commit_hash['message'] = commit.message
					commit_hash['url'] = (config.urls['commit'] || config.commit_url) % commit.sha
					commit_hash['author'] = {
						'name'  => commit.author.name,
						'email' => commit.author.email
					}

					# accomodate the odd formatting they have in their timestamp
					timestamp = commit.authored_date.gmtime.strftime('%FT%T%z')
					commit_hash['timestamp'] = timestamp[0..-3] + ':' + timestamp[-2..-1]

					# figure out what, if any files should be added to the 
					# removed, added, or modified arrays
					commit_hash['removed']  = []
					commit_hash['added']    = []
					commit_hash['modified'] = []
					commit.diffs.each do |diff|
						commit_hash['removed']  << diff.a_path if diff.deleted_file
						commit_hash['added']    << diff.b_path if diff.new_file
						commit_hash['modified'] << diff.a_path if !diff.new_file && !diff.deleted_file
					end
				end
			end
		end

		hash_to_return
	end
end