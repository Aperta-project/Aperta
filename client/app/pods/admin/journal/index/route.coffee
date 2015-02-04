`import Ember from 'ember'`

JournalIndexRoute = Ember.Route.extend
  fetchAdminJournalUsers: (journalId) ->
    @store.find 'AdminJournalUser', journal_id: journalId
    .then (users) => @set 'controller.adminJournalUsers', users

  setupController: (controller, model) ->
    @_super controller, model
    controller.set('doiStartNumberEditable', Ember.isEmpty(model.get('lastDoiIssued')))
    @fetchAdminJournalUsers model.get('id')

  deactivate: ->
    @set 'controller.adminJournalUsers', null
    @set 'controller.doiEditState', false

  actions:
    openEditOverlay: (key) ->
      @controllerFor('overlays/adminJournal').setProperties
        model: @modelFor('admin/journal/index')
        propertyName: key

      @render "overlays/admin-journal-#{key.dasherize()}",
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/adminJournal'

    editEPubCSS: ->
      @send 'openEditOverlay', 'epubCss'

    editPDFCSS: ->
      @send 'openEditOverlay', 'pdfCss'

    editManuscriptCSS: ->
      @send 'openEditOverlay', 'manuscriptCss'

    editTaskTypes: ->
      @render 'overlays/editTaskTypes',
        into: 'application'
        outlet: 'overlay'
        controller: 'overlays/editTaskTypes'

`export default JournalIndexRoute`
