`import Ember from 'ember'`
`import Table from 'tahi/models/table'`

EditTablesController = Ember.Controller.extend
  # initialized via paper/edit/route
  paper: Ember.computed.alias('model')

  # intitialized via template
  toolbar: null

  needs: ['paper/edit']

  manuscriptEditor: null

  tables: Ember.computed.alias('paper.tables')

  actions:

    updateToolbar: (newState)->
      toolbar = @get('toolbar');
      if toolbar
        lastState = @get('lastState')
        if not lastState or newState.hasSelection() or lastState.editor == newState.editor
          # skip if the update is due to a blur while another editor has been focused already
          toolbar.updateState(newState);
          @set('lastState', newState)

    addTable: ->
      table = @store.createRecord 'table',
        #id: Table.uuid()
        paper: @get('paper')
        title: 'Enter title here'
        body: """
         <table>
           <thead><tr><th>A</th><th>B</th><th>C</th><th>D</th><th>E</th><th>F</th><th>G</th><th>H</th></tr></thead>
           <tbody>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
             <tr><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td><td><p> </p></td></tr>
           </tbody>
         </table>
        """
        caption: 'Enter caption here'
      @get('paper.tables').pushObject(table)
      table.save().then =>
        @get('paper').save()

    destroyTable: (table) ->
      console.log('Destroying table', table.get('id'))
      @get('paper.tables').removeObject(table)
      table.destroyRecord().then =>
        @get('paper').save()

`export default EditTablesController`
