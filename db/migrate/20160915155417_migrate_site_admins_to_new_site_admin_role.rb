# This data migration ensures that site admins using the users.site_admin
# column flag are migrated to the R&P data model.
class MigrateSiteAdminsToNewSiteAdminRole < DataMigration
  RAKE_TASK_UP = 'data:migrate:migrate_site_admins_to_role'
  RAKE_TASK_DOWN ='data:migrate:migrate_site_admin_role_back_to_column'
end
