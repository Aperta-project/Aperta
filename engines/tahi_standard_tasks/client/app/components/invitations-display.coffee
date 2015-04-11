`import Ember from 'ember';`
`import layout from '../templates/components/invitations-display';`

InvitationsDisplay = Ember.Component.extend
  layout: layout
  tagName: 'table'
  classNames: ['invitees']

  latestDecisionInvitations: Ember.computed 'latestDecision.invitations', 'decisions.@each.invitations', ->
    @get('latestDecision.invitations').filterBy('invitationType', 'Reviewer')

  previousDecisions: Em.computed 'latestDecision.invitations', 'decisions.@each.invitations', ->
    @get('decisions').without @get('latestDecision')

  previousDecisionsWithFilteredInvitations: Em.computed 'previousDecisions', 'decisions.@each', 'latestDecision', ->
    @get('previousDecisions').map (decision) =>
      decision.set 'filteredInvitations', decision.get('invitations').filterBy('invitationType', @get('invitationType'))
      decision


  actions:
    destroyInvitation: (invitation) ->
      @sendAction 'onDestroyInvitation', invitation

`export default InvitationsDisplay`
