import Ember from 'ember';

export default Ember.Mixin.create({
  needs: ['overlays/paperSubmit'],
  editor: null,
  saveState: false,
  isSaving: false,
  errorText: '',
  defaultBody: 'Type your manuscript here',

  isBodyEmpty: Ember.computed('model.body', function() {
    return Ember.isBlank($(this.get('model.body')).text());
  }),

  statusMessage: Ember.computed.any('processingMessage', 'userEditingMessage', 'saveStateMessage'),

  processingMessage: function() {
    return this.get('model.status') === 'processing' ? 'Processing Manuscript' : null;
  }.property('model.status'),

  userEditingMessage: function() {
    if (this.get('model.lockedBy') && !this.get('lockedByCurrentUser')) {
      return '<span class="edit-paper-locked-by">' + this.get('model.lockedBy.fullName') + '</span> <span>is editing</span>';
    } else {
      return null;
    }
  }.property('model.lockedBy', 'lockedByCurrentUser'),

  isEditing: Ember.computed.alias('lockedByCurrentUser'),

  cannotEdit: function() {
    return this.get('model.status') === 'processing' || !this.get('lockedByCurrentUser');
  }.property('model.status', 'lockedByCurrentUser'),

  canEdit: Ember.computed.not('cannotEdit'),

  canToggleEditing: function() {
    return this.get('canEdit') || Ember.isEmpty(this.get('model.lockedBy'));
  }.property('model.lockedBy', 'canEdit'),

  lockedByCurrentUser: function() {
    let lockedBy = this.get('model.lockedBy');
    return !!(lockedBy && lockedBy === this.get('currentUser'));
  }.property('model.lockedBy'),

  saveStateDidChange: function() {
    this.setProperties({
      saveStateMessage: this.get('saveState') ? 'Saved' : null,
      savedAt: this.get('saveState') ? new Date() : null
    });
  }.observes('saveState'),

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
    },

    confirmSubmitPaper() {
      if (!this.get('model.allMetadataTasksCompleted')) { return; }

      this.get('model').save();
      this.get('controllers.overlays/paperSubmit').set('model', this.get('model'));
      this.send('showConfirmSubmitOverlay');
    }
  }
});
