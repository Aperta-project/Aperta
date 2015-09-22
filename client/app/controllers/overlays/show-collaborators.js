import Ember from 'ember';

const { computed } = Ember;

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen show-collaborators-overlay',
  availableCollaborators: computed.setDiff('allUsers', 'collaborators'),

  formattedCollaborators: computed('availableCollaborators.@each', function() {
    return this.get('availableCollaborators').map(function(collab) {
      return {
        id: collab.get('id'),
        text: collab.get('fullName')
      };
    });
  }),

  addedCollaborations: computed.setDiff('collaborations', 'initialCollaborations'),
  removedCollaborations: computed.setDiff('initialCollaborations', 'collaborations'),
  allUsers: null,
  selectedCollaborator: null,
  paper: null,
  initialCollaborations: null,

  collaborations: null,
  collaborators: computed('collaborations.[]', function() {
    return this.get('collaborations').mapBy('user');
  }),

  actions: {
    addNewCollaborator(formattedOption) {
      let paper = this.get('paper');
      let newCollaborator = this.get('availableCollaborators').findBy('id', formattedOption.id);

      // if this collaborator's record was previously removed from the paper make sure we use THAT one and not a new record.
      let existingRecord = this.store.peekAll('collaboration').find(function(c) {
        return c.get('oldPaper') === paper && c.get('user') === newCollaborator;
      });

      let newCollaboration = existingRecord || this.store.createRecord('collaboration', {
        paper: paper,
        user: newCollaborator
      });

      this.get('collaborations').addObject(newCollaboration);
    },

    removeCollaborator(collaborator) {
      let collaboration = this.get('collaborations').findBy('user', collaborator);

      // since the relationship between paper and collaboration is a proper hasMany, if we remove the
      // collaboration from the papers' collection of them ember will also unset the paper field on the collaboration.
      // if the user tries to re-add that collaborator to the paper without reloading we need to do some extra checking
      // to make sure that ember doesn't create a new record but rather uses the one we just removed here.
      collaboration.set('oldPaper', collaboration.get('paper'));
      this.get('collaborations').removeObject(collaboration);
      this.set('selectedCollaborator', null);
    },

    cancel() {
      let collaborations = this.get('collaborations');
      // we have to remove/add the changed collaborations from their associations individually
      this.get('removedCollaborations').forEach(function(c) { return collaborations.addObject(c); });
      this.get('addedCollaborations').forEach(function(c)   { return collaborations.removeObject(c); });
      this.send('closeOverlay');
    },

    save() {
      let addPromises = this.get('addedCollaborations').map(function(collaboration) {
        return collaboration.save();
      });

      let deletePromises = this.get('removedCollaborations').map(function(collaboration) {
        return collaboration.destroyRecord();
      });

      Ember.RSVP.all(addPromises.concat(deletePromises)).then(()=> {
        this.send('closeOverlay');
      });
    }
  }
});
