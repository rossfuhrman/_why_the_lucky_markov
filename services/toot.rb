require 'rubygems'
require 'bundler/setup'
require 'mastodon'
require 'octokit'
require './services/scripter'

class Toot

  def self.go
    publish_new_toot
    process_old_issues
  end

  def self.repo_url
    "rossfuhrman/#{ENV["WHYBOT_GITHUB_REPO"]}"
  end

  def self.new_toot
    toot = Scripter.markov
  end

  def self.post_a_new_toot_to_mastodon(toot, github_issue_url)
    whybot0_instance_url = "https://botsin.space"
    masto_client = Mastodon::REST::Client.new(base_url: whybot0_instance_url, bearer_token: ENV["WHYBOT0_BEARER_TOKEN"])
    toot = toot + "\r Comment on this issue to upvote it: #{github_issue_url}"
    puts "Posting Phase I of toot: #{toot}"
    masto_client.create_status(toot)
  end

  def self.create_github_issue_from_toot(toot)
    puts "creating issue for toot: #{toot}"
    description = "Toot: #{toot} \n One comment = 1 upvote. Sometime after this gets #{ENV["WHYBOT_POSTING_THRESHOLD"]} upvotes, it will be posted to the main account at https://mastodon.xyz/@_why_toots "
    github_client.create_issue(repo_url, toot, description)
  end

  def self.publish_new_toot
    toot = new_toot
    new_github_issue = create_github_issue_from_toot(toot)
    post_a_new_toot_to_mastodon(toot, new_github_issue.html_url)
  end


  def self.post_phase_ii_of_new_toot(toot)
    puts "Posting Phase II of toot: #{toot}"

    whybot_good_stuff_instance_url = "https://mastodon.xyz"
    masto_client = Mastodon::REST::Client.new(base_url: whybot_good_stuff_instance_url, bearer_token: ENV["GOOD_STUFF_WHYBOT_TOKEN"])

    masto_client.create_status(toot)
  end

  def self.process_old_issues

    open_issues_by_owner = github_client.issues(repo_url, state: "open", creator: ENV["WHYBOT_GITHUB_USER"])

    #ugggghhh
    initial_comment = 1

    open_issues_by_owner.each do |issue|
      #TODO this doesn't prevent anyone from spamming the upvotes
      if issue.comments - initial_comment >= ENV["WHYBOT_POSTING_THRESHOLD"].to_i
        post_phase_ii_of_new_toot(issue.title)
        puts "closing issue for toot: #{toot}"
        github_client.close_issue(repo_url, issue.number)
      end
    end
  end

  def self.github_client
    Octokit::Client.new(:login => ENV["WHYBOT_GITHUB_USER"], :password => ENV["WHYBOT_GITHUB_PASSWORD"])
  end

end
