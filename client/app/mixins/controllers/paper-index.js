import Ember from 'ember';

const { computed } = Ember;

export default Ember.Mixin.create({
  editor: null,
  saveState: false,
  isSaving: false,
  errorText: '',
  defaultBody: 'Type your manuscript here',

  isBodyEmpty: computed('model.body', function() {
    return Ember.isBlank($(this.get('model.body')).text());
  }),

  statusMessage: computed.any('processingMessage', 'userEditingMessage', 'saveStateMessage'),

  processingMessage: computed('model.status', function() {
    return this.get('model.status') === 'processing' ? 'Processing Manuscript' : null;
  }),

  userEditingMessage: computed('model.lockedBy', 'lockedByCurrentUser', function() {
    if (this.get('model.lockedBy') && !this.get('lockedByCurrentUser')) {
      return '<span class="edit-paper-locked-by">' +
             this.get('model.lockedBy.fullName')   +
             '</span> <span>is editing</span>';
    } else {
      return null;
    }
  }),

  isEditable: computed('model.lockedBy', function() {
    return this.get('lockedByCurrentUser');
  }),

  cannotEdit: computed('model.status', 'lockedByCurrentUser', function() {
    return this.get('model.status') === 'processing' || !this.get('lockedByCurrentUser');
  }),

  canEdit: computed.not('cannotEdit'),

  canToggleEditing: computed('model.lockedBy', 'canEdit', function() {
    return this.get('canEdit') || Ember.isEmpty(this.get('model.lockedBy'));
  }),

  lockedByCurrentUser: computed('model.lockedBy', function() {
    let lockedBy = this.get('model.lockedBy');
    return !!(lockedBy && lockedBy === this.get('currentUser'));
  }),

  saveStateDidChange: Ember.observer('saveState', function() {
    this.setProperties({
      saveStateMessage: this.get('saveState') ? 'Saved' : null,
      savedAt: this.get('saveState') ? new Date() : null
    });
  }),

  savePaperDebounced() {
    this.set('isSaving', true);
    Ember.run.debounce(this, this.savePaper, 2000);
  },

  actions: {
    toggleEditing() {
      if (this.get('model.lockedBy')) {
        this.stopEditing();
      } else {
        this.startEditing();
      }
    },

    savePaper() {
      this.savePaperDebounced();
    },

    updateDocumentBody(content) {
      this.set('model.body', content);
    }
  }
});
