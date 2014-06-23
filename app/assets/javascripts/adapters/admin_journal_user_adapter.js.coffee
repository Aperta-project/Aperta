ETahi.AdminJournalUserAdapter = DS.ActiveModelAdapter.extend
  headers:
    'Tahi-Authorization-Check': true
  pathForType: (type) ->
    'admin/journal_users'
