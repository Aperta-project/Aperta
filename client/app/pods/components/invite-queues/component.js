import Ember from 'ember';
export default Ember.Component.extend({
  store: Ember.inject.service(),
  queueParent: null,
  task: null,

  _mainQueue: null,
  mainQueue: Ember.computed('queueParent', '_mainQueue', function() {
    let mainQueue;

    if (this.get('_mainQueue')) { return this.get('_mainQueue'); }

    if (!this.get('queueParent')) { return null; }

    const queueParent = this.get('queueParent');
    let queues = queueParent.get('inviteQueues');
    if (queues.get('length')) {
      mainQueue = queues.findBy('mainQueue');
      this.set('_mainQueue', mainQueue);
      return mainQueue;
    } else {
      var decision;
      if (queueParent.get('constructor.modelName') === 'decision') {
        decision = queueParent;
      }
      // TODO: it feels like having an invite queue is now a requirement for each decision,
      // and for the paper editor task or any task that needs queues.  I think we should create
      // this on the server side when those objects are first created rather than on-demand
      // like we're doing now.
      mainQueue = this.get('store').createRecord('inviteQueue', {
        queueTitle: 'Main',
        mainQueue: true,
        task: this.get('task'),
        decision: decision
      });
      queueParent.get('inviteQueues').addObject(mainQueue);
      mainQueue.save();
      this.set('_mainQueue', mainQueue);
      return mainQueue;
    }
  }),

  queueSortingCriteria: ['mainQueue'],

  getOrCreateSubQueue(primary) {
    let mainQueue = this.get('mainQueue');
    let primaryQueue = primary.get('inviteQueue');
    if(primaryQueue !== mainQueue){
      return Ember.RSVP.resolve(primaryQueue);
    }

    // reassign the primary into the new subqueue
    const queueParent = this.get('queueParent');
    const subQueue = queueParent.get('inviteQueues').createRecord({
      primary: primary,
      mainQueue: false,
      queueTitle: `SubQueue for: ${primary.get('email')}`,
      task: this.get('task')
    });
    queueParent.get('inviteQueues').addObject(subQueue);
    primary.set('inviteQueue', subQueue);
    return Ember.RSVP.all([primary.save(), subQueue.save()]);
  },

  actions: {
    destroyInvite(invitation) {
      if (invitation.get('inviteQueue.invitations.length') === 2) {
        const subQueue = invitation.get('inviteQueue');
        const primary = invitation.get('primary');
        primary.set('inviteQueue', this.get('mainQueue'));
        primary.save();
        subQueue.destroyRecord();
      }
      invitation.get('inviteQueue.invitations').removeObject(invitation);
      invitation.destroyRecord();
    },

    placeInDifferentQueue(invitation) {
      const primary = invitation.get('primary');
      if (primary) {
        return this.getOrCreateSubQueue(primary).then(function([_primary, subQueue]) {
          invitation.set('inviteQueue', subQueue);
          if (primary.get('inviteQueue') !== subQueue) {
            primary.set('inviteQueue', subQueue);
          }
          return invitation.save();
        });
      } else {
        invitation.set('inviteQueue', this.get('mainQueue'));
        return invitation.save();
      }
    }
  }
});
