`import DS from 'ember-data'`

Decision = DS.Model.extend
  letter: DS.attr("string")
  revisionNumber: DS.attr("number")
  verdict: DS.attr("string")
  paper: DS.belongsTo("paper")
  isLatest: DS.attr("boolean")
  invitations: DS.hasMany("invitation")
  revisionHumanNumber: Em.computed 'revisionNumber', ->
    @get('revisionNumber') + 1
  createdAt: DS.attr("date")
}

`export default Decision`
