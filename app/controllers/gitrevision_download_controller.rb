require 'grit'

class GitrevisionDownloadController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => [:index]
  #skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    is_branch = false
    is_tag = false
    commit = nil
    return unless @project
    # we check that the module is enabled
    if not @project.module_enabled?('gitrevision_download')
      render_404
      return
    end

    repository = @project.repository
    if repository.nil?
      flash.now[:error] = l(:project_no_repository, :name => @project.to_s)
      render_404
      return
    end
=begin
# This will be handled by Grit itself
    if repository.type != "Git"
      flash.now[:error] = l(:repo_not_git, :name => @project.to_s)
      render_404
      return
    end
=end
    
    if not params[:rev]
      rev = "master"
    else
      rev = params[:rev]
    end
    # init repository
    begin
      repo = Grit::Repo.new(repository.url, :is_bare => true)
    rescue Grit::NoSuchPathError => e
      flash.now[:error] = l(:repo_path_not_found)
      render_404
      return
    rescue Grit::InvalidGitRepositoryError => e
      flash.now[:error] = l(:repo_invalid)
      render_404
      return
    rescue Exception => e
      flash.now[:error] = l(:unknown_exception)
      render_404
      return
    end

    # is the revision  branch?
    repo.heads.each do |x|
      if x.name == rev
        is_branch = true
        commit = x.commit
        break
      end
    end
    # is the revision a tag?
    if commit.nil?
      repo.tags.each do |x|
        if x.name == rev
          is_tag = true
          commit = x.commit
          break
        end
      end
    end
    # well, let check if this is a commit then
    if commit.nil?
      commit = rev
    end

    commit_obj = repo.commits("#{commit.to_s}",1).first
    
    if commit_obj.nil?
      flash.now[:error] = l(:not_such_commit, :commit => commit)
      render_404
      return
    end

    is_gzipped = Setting.plugin_redmine_gitrevision_download[:gzip] ? true : false
    content = ""
    timeout = Setting.plugin_redmine_gitrevision_download[:timeout].to_f
    max_size = Setting.plugin_redmine_gitrevision_download[:max_size].to_i
    Grit::Git.git_timeout = timeout
    Grit::Git.git_max_size = max_size

    begin
      content = repo.archive_tar(commit.to_s, "#{@project.to_s}-#{rev}/")
    rescue Grit::Git::GitTimeout => e
      flash.now[:error] = l(:git_archive_timeout, :timeout => timeout, :bytes_read => e.bytes_read)
      render_404
      return
    end
    # Gzip content
    if is_gzipped
        content = ActiveSupport::Gzip.compress(content)
    end

    send_data(content, :filename => "#{@project.to_s}-#{rev}.tar" + (is_gzipped ? ".gz" : ""), :type => is_gzipped ? 'application/x-gzip' : 'application/x-tar')
  end

  private
  # Finds the Redmine project in the database based on the given project identifier
  def find_project
    begin
      @project = Project.find(params[:project_id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = l(:project_not_found)
      render_404
      @project = nil
    rescue Excepion => e
      flash.now[:error] = l(:unknown_exception)
      render_404
      @project = nil
    end
  end

end
