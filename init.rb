require 'redmine'

Redmine::Plugin.register :redmine_gitrevision_download do
  name 'Redmine Gitrevision Download plugin'
  author 'Emmanuel Bretelle'
  description 'A plugin adding a download link to git repository browser'
  version '0.0.1'
end
