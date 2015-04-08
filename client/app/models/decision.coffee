`import DS from 'ember-data'`

Decision = DS.Model.extend {
  letter: DS.attr("string")
  revisionNumber: DS.attr("number")
  verdict: DS.attr("string")
  paper: DS.belongsTo("paper")
}

`export default Decision`
