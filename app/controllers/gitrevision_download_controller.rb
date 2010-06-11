require 'grit'

class GitrevisionDownloadController < ApplicationController

  before_filter :find_project
  #skip_before_filter :verify_authenticity_token, :check_if_login_required

  def index
    is_branch = false
    is_tag = false
    commit = nil
    return unless @project
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

   
    content = repo.archive_tar_gz(commit.to_s, "#{@project.to_s}-#{rev}/")
   
    headers['Content-Disposition'] = "attachment; filename=#{@project.to_s}-#{rev}.tar.gz"
    render(:content_type => 'application/x-gzip', :text => content)
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
