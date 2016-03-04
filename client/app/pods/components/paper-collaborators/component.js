import Ember from 'ember';
import getOwner from 'ember-getowner-polyfill';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

const { computed } = Ember;
const { setDiff } = computed;

export default Ember.Component.extend(EscapeListenerMixin, {
  init() {
    this._super(...arguments);
    this.set('store', getOwner(this).lookup('store:main'));

    const collaborations = this.get('paper.collaborations') || [];
    this.setProperties({
      allUsers: this.get('store').find('user'),
      collaborations: collaborations,
      initialCollaborations: collaborations.slice()
    });
  },

  availableCollaborators: computed.setDiff('allUsers', 'collaborators'),

  formattedCollaborators: computed('availableCollaborators.[]', function() {
    return this.get('availableCollaborators').map(function(collab) {
      return {
        id: collab.get('id'),
        text: collab.get('fullName')
      };
    });
  }),

  addedCollaborations: setDiff('collaborations', 'initialCollaborations'),
  removedCollaborations: setDiff('initialCollaborations', 'collaborations'),
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
      const paper = this.get('paper');
      const newCollaborator = this.get('availableCollaborators')
                                  .findBy('id', formattedOption.id);

      // if this collaborator's record was previously removed from the paper
      // make sure we use THAT one and not a new record.

      const existingRecord = this.store.all('collaboration').find(function(c) {
        return c.get('oldPaper') === paper && c.get('user') === newCollaborator;
      });

      const newCollaboration = existingRecord || this.store.createRecord(
        'collaboration',
        {
          paper: paper,
          user: newCollaborator
        }
      );

      this.get('collaborations').addObject(newCollaboration);
    },

    removeCollaborator(collaborator) {
      const collaboration = this.get('collaborations')
                                .findBy('user', collaborator);

      // since the relationship between paper and collaboration is
      // a proper hasMany, if we remove the collaboration from the papers'
      // collection of them ember will also unset the paper field on
      // the collaboration. If the user tries to re-add that collaborator
      // to the paper without reloading we need to do some extra checking
      // to make sure that ember doesn't create a new record but rather
      // uses the one we just removed here.
      collaboration.set('oldPaper', collaboration.get('paper'));
      this.get('collaborations').removeObject(collaboration);
      this.set('selectedCollaborator', null);
    },

    cancel() {
      const collaborations = this.get('collaborations');
      // we have to remove/add the changed collaborations from
      // their associations individually
      this.get('removedCollaborations').forEach(function(c) {
        return collaborations.addObject(c);
      });

      this.get('addedCollaborations').forEach(function(c) {
        return collaborations.removeObject(c);
      });

      this.attrs.close();
    },

    save() {
      const added = this.get('addedCollaborations');
      const removed = this.get('removedCollaborations');

      const addPromises = added.map(function(collaboration) {
        return collaboration.save();
      });

      const deletePromises = removed.map(function(collaboration) {
        return collaboration.destroyRecord();
      });

      Ember.RSVP.all(addPromises.concat(deletePromises)).then(()=> {
        this.attrs.close();
      });
    },

    close() {
      this.attrs.close();
    }
  }
});
