class GitrevisionDownloadHookListener < Redmine::Hook::ViewListener
  render_on :view_repositories_show_contextual,
    :partial => 'hooks/gitrevision_download/_navigation'
end
