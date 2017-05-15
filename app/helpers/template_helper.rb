module TemplateHelper
  def app_name
    TahiEnv.app_name
  end

  def git_commit_id_meta_tag
    tag(:meta,
        { name: "git-commit-id",
          content: Rails.configuration.x.git_commit_id },
        true)
  end
end
