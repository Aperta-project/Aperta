`import Ember from 'ember'`

FunderInfluenceStatementView = Ember.View.extend
  templateName: 'funder-influence-statement'
  funderInflunce: Em.computed 'funder.funderHadInfluence', 'funder.funderInfluenceDescription', ->
    if @get('funder.funderHadInfluence')
      @get 'funder.funderInfluenceDescription'
    else if @get('funder.funderHadInfluence') is false
      "The funder had no role in study design, data collection and analysis, decision to publish, or preparation of the manuscript."

`export default FunderInfluenceStatementView`
