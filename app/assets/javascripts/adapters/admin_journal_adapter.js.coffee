ETahi.AdminJournalAdapter = DS.ActiveModelAdapter.extend
  headers:
    'Tahi-Authorization-Check': true
  pathForType: (type) ->
    'admin/journals'
