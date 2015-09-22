`import Ember from 'ember';`
`import layout from '../templates/components/invitations-display';`

InvitationsDisplay = Ember.Component.extend
  layout: layout
  tagName: 'table'
  classNames: ['invitees']
  latestDecision: null

  latestDecisionInvitations: Ember.computed 'latestDecision', 'latestDecision.invitations', 'latestDecision.invitations.[]', ->
    # latestDecision is the resolution of a promise; give it a sec to arrive.
    if @get('latestDecision.invitations')
      @get('latestDecision.invitations').filterBy 'invitationType', 'Reviewer'

  previousDecisions: Em.computed 'decisions', ->
    @get('decisions').without @get('latestDecision')

  previousDecisionsWithFilteredInvitations: Em.computed 'previousDecisions', 'previousDecisions.[]', ->
    @get('previousDecisions').map (decision) =>
      filteredInvitations = decision.get('invitations').filterBy('invitationType', @get 'invitationType')
      decision.set 'filteredInvitations', filteredInvitations
      decision

  actions:
    destroyInvitation: (invitation) ->
      @sendAction 'onDestroyInvitation', invitation

`export default InvitationsDisplay`
