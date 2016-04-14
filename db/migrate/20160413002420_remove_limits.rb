class RemoveLimits < ActiveRecord::Migration
  def change
    change_column :affiliations, :name, :string, limit: nil
    change_column :affiliations, :email, :string, limit: nil

    change_column :api_keys, :access_token, :string, limit: nil

    change_column :attachments, :file, :string, limit: nil
    change_column :attachments, :title, :string, limit: nil
    change_column :attachments, :caption, :string, limit: nil
    change_column :attachments, :status, :string, limit: nil

    change_column :authors, :first_name, :string, limit: nil
    change_column :authors, :last_name, :string, limit: nil

    change_column :credentials, :provider, :string, limit: nil
    change_column :credentials, :uid, :string, limit: nil

    change_column :figures, :attachment, :string, limit: nil
    change_column :figures, :title, :string, limit: nil
    change_column :figures, :status, :string, limit: nil

    change_column :journal_task_types, :title, :string, limit: nil
    change_column :journal_task_types, :old_role, :string, limit: nil
    change_column :journal_task_types, :kind, :string, limit: nil

    change_column :journals, :name, :string, limit: nil
    change_column :journals, :logo, :string, limit: nil
    change_column :journals, :epub_cover, :string, limit: nil
    change_column :journals, :epub_css, :string, limit: nil
    change_column :journals, :doi_publisher_prefix, :string, limit: nil
    change_column :journals, :doi_journal_prefix, :string, limit: nil
    change_column :journals, :last_doi_issued, :string, limit: nil

    change_column :manuscript_manager_templates, :paper_type, :string, limit: nil

    change_column :old_roles, :name, :string, limit: nil
    change_column :old_roles, :kind, :string, limit: nil

    change_column :paper_roles, :old_role, :string, limit: nil

    change_column :papers, :short_title, :string, limit: nil
    change_column :papers, :paper_type, :string, limit: nil

    change_column :phase_templates, :name, :string, limit: nil

    change_column :phases, :name, :string, limit: nil

    change_column :question_attachments, :attachment, :string, limit: nil
    change_column :question_attachments, :title, :string, limit: nil
    change_column :question_attachments, :status, :string, limit: nil

    change_column :supporting_information_files, :title, :string, limit: nil
    change_column :supporting_information_files, :caption, :string, limit: nil
    change_column :supporting_information_files, :attachment, :string, limit: nil
    change_column :supporting_information_files, :status, :string, limit: nil

    change_column :tahi_standard_tasks_funders, :name, :string, limit: nil
    change_column :tahi_standard_tasks_funders, :grant_number, :string, limit: nil
    change_column :tahi_standard_tasks_funders, :website, :string, limit: nil

    change_column :task_templates, :title, :string, limit: nil

    change_column :tasks, :title, :string, limit: nil
    change_column :tasks, :type, :string, limit: nil
    change_column :tasks, :old_role, :string, limit: nil

    change_column :tasks, :old_role, :string, limit: nil

    change_column :users, :first_name, :string, limit: nil
    change_column :users, :last_name, :string, limit: nil
    change_column :users, :email, :string, limit: nil
    change_column :users, :encrypted_password, :string, limit: nil
    change_column :users, :reset_password_token, :string, limit: nil
    change_column :users, :current_sign_in_ip, :string, limit: nil
    change_column :users, :last_sign_in_ip, :string, limit: nil
    change_column :users, :username, :string, limit: nil
    change_column :users, :avatar, :string, limit: nil
  end
end
