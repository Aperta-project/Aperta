ETahi.JournalIndexRoute = Ember.Route.extend
  fetchAdminJournalUsers: (journalId) ->
    @store.find 'AdminJournalUser', journal_id: journalId
    .then (users) => @set 'controller.adminJournalUsers', users

  setupController: (controller, model) ->
    @_super controller, model
    @fetchAdminJournalUsers model.get('id')

  deactivate: -> @set 'controller.adminJournalUsers', null

  actions:
    openEditOverlay: (key) ->
      @controllerFor('adminJournalOverlay').setProperties
        model: @modelFor('journalIndex')
        propertyName: key
      @render "adminJournal#{key.capitalize()}Overlay",
        into: 'application'
        outlet: 'overlay'
        controller: 'adminJournalOverlay'

    editEPubCSS: ->
      @send 'openEditOverlay', 'epubCss'

    editPDFCSS: ->
      @send 'openEditOverlay', 'pdfCss'

    editManuscriptCSS: ->
      @send 'openEditOverlay', 'manuscriptCss'

    editTaskTypes: ->
      @render 'editTaskTypesOverlay',
        into: 'application'
        outlet: 'overlay'
        controller: 'editTaskTypesOverlay'
