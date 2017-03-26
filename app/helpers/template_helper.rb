module TemplateHelper
  def app_name
    TahiEnv.app_name
  end

  def git_commit_id_meta_tag
    content_tag(:meta, nil,
                name: "git-commit-id",
                content: Rails.configuration.x.git_commit_id)
  end
end
