# repository_utils

This repository holds scripts that can be used to create a list of issues or PRs
to help with writing release notes.  It uses octokit to request the information
from GitHub and from a specified date, sorted by date.

## To use

Clone this repository.

```
gem install octokit
```

## Scripts

### List Issues

This script creates a list of all issues that were closed between <oldest_date> and today, inclusive.
It will also create a list per label of the same set of issues sorted by the labels assigned to
each issue.  Issues will appear in multiple lists if multiple labels are assigned to the issue.

```
  ruby list-issues-closed-since.rb <oldest_date> <github_organization> <github_repo> <github_username> <github_access_token>
```

where
* <oldest_date> - identifies the oldest date that an issue was closed 
* <github_organization> - identifies the organization holding the repository
* <github_repo> - identifies the repository for which you want to list issues
* <github_username> - identifies your personal repository location in GitHub
* <github_access_token> - the access token that allows the test repo to be created under your Repositories

Output:
* a list with all issues sorted from most recent to oldest close date
* a list per label assigned to issues in the all issues list which includes issues in the date range that are assigned that label


### List PRs

