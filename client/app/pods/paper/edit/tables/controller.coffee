`import Ember from 'ember'`

EditTablesController = Ember.Controller.extend FileUploadMixin,
  # initialized via paper/edit/route
  paper: Ember.computed.alias('model')

  # intitialized via template
  toolbar: null

  needs: ['paper/edit']

  manuscriptEditor: Ember.computed.alias('controllers.paper/edit.editor')

  actions:

    updateToolbar: (newState)->
      toolbar = @get('toolbar');
      if toolbar
        lastState = @get('lastState')
        if not lastState or newState.hasSelection() or lastState.editor == newState.editor
          # skip if the update is due to a blur while another editor has been focused already
          toolbar.updateState(newState);
          @set('lastState', newState)

`export default EditTablesController`
