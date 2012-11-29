# It requires the file in lib/gitrevision_download/hooks.rb
require_dependency 'gitrevision_download/gitrevision_download_hook_listener'

Redmine::Plugin.register :redmine_gitrevision_download do
  name 'Redmine Gitrevision Download plugin'
  author 'Emmanuel Bretelle'
  author_url 'http://www.debuntu.org'
  url 'http://redmine.debuntu.org/projects/gitrevision-download'
  description 'A plugin adding a download link to git repository browser'
  version '0.0.8'

  settings :default => { :gzip => 1 }, :partial => 'settings/gitrevision_download_settings'
  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :gitrevision_download do
    permission :view_gitrevision_download, :gitrevision_download => :index
  end
end
