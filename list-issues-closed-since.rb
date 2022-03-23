#!/usr/bin/env ruby
# frozen_string_literal: true

# Github script to get a list of issues closed since a given date.
oldest_date = ARGV[0]

org_name = ARGV[1]
repo_name = ARGV[2]

username = ARGV[3]
github_token = ARGV[4]

unless oldest_date && org_name && repo_name && username && github_token
  puts 'Argument Error: oldest_date, GitHub username and GitHub access token required'
  puts ''
  puts 'USAGE'
  puts '    ruby list-issues-closed-since.rb <oldest_date> <github_organization> <github_repo> <github_username> <github_access_token>'
  puts ''
  puts 'DESCRIPTION'
  puts '  List all issues that were closed starting on <oldest_date> up to today.  Also includes'
  puts '  lists for each label assigned to an issue.  Issues will appear in multiple lists if'
  puts '  multiple labels are assigned.'
  puts ''
  puts '    <oldest_date> - date the issue was closed for the oldest issues to include (e.g. 2022-03-01)'
  puts '    <github_organization> - identifies the organization holding the repository'
  puts '    <github_repo> - identifies the repository for which you want to list issues'
  puts '    <github_username> - identifies your personal repository location in GitHub'
  puts '    <github_access_token> - the access token that allows the test repo to be created under your Repositories'
  puts ''
  return
end

require 'octokit'

client = Octokit::Client.new({ access_token: github_token });

since_date = Date.parse(oldest_date)
now_date = Time.now.to_date

options = {}
options[:page] = 1
options[:state] = 'closed'
options[:sort] = 'updated'
options[:direction] = 'desc'
options[:since] = since_date.strftime("%Y-%m-%dT00:00:00Z")

all_issues = []
by_label_issues = {}

puts "All Issues"
issues = client.list_issues("#{org_name}/#{repo_name}", options)
while(issues.count > 0)
  issues.each do |issue|
    issue_info = {
      number: issue[:number],
      url: issue[:html_url],
      title: issue[:title],
      state: issue[:state],
      closed_at: issue[:closed_at].strftime("%Y-%m-%d")
    }

    if !issue.key?(:pull_request) || issue[:pull_request] == {}
      issue_info[:pull_request] = { 'to_s' => "" }
    else
      pr_info = {
        url: issue[:pull_request][:html_url],
        number: issue[:pull_request][:html_url].split('/').last,
        merged_at: issue[:pull_request][:merged_at] }
      pr_info[:to_s] = " See [PR #{pr_info[:number]}](#{pr_info[:url]}) (merged: #{pr_info[:merged_at]})"
      issue_info[:pull_request] = pr_info
    end
    puts "- [ ] [Issue #{issue_info[:number]}](#{issue_info[:url]}) - #{issue_info[:title]} (closed: #{issue_info[:closed_at]})#{issue_info[:pull_request][:to_s]}"

    labels = issue[:labels].map &:name
    labels.each do |label|
      by_label_issues[label] = [] unless by_label_issues.key?(label)
      by_label_issues[label] << issue_info
    end
  end

  options[:page] += 1
  issues = client.list_issues("#{org_name}/#{repo_name}", options)
end

puts ""
by_label_issues.each do |label_name, label_issues|
  puts ""
  puts "Issues for Label: #{label_name}"
  label_issues.each do |issue_info|
    puts "* [Issue #{issue_info[:number]}](#{issue_info[:url]}) - #{issue_info[:title]} (closed: #{issue_info[:closed_at]})#{issue_info[:pull_request][:to_s]}"
  end
end
