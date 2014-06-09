ETahi.AdminJournalAdapter = DS.ActiveModelAdapter.extend
  headers:
    'TAHI_AUTHORIZATION_CHECK': true
  pathForType: (type) ->
    'admin/journals'
