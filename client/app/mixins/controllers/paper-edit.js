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
    if (this.get('model.status') === 'processing') {
      return 'Processing Manuscript';
    } else {
      return null;
    }
  }.property('model.status'),

  userEditingMessage: (function() {
    let lockedBy = this.get('model.lockedBy');

    if (lockedBy && lockedBy !== this.get('currentUser')) {
      return '<span class="edit-paper-locked-by">' + (lockedBy.get('fullName')) + '</span> <span>is editing</span>';
    } else {
      return null;
    }
  }).property('model.lockedBy'),

  locked: function() {
    return !Ember.isBlank(this.get('processingMessage') || this.get('userEditingMessage'));
  }.property('processingMessage', 'userEditingMessage'),

  canEdit: Ember.computed.not('locked'),

  isEditing: function() {
    let lockedBy = this.get('model.lockedBy');
    return lockedBy && lockedBy === this.get('currentUser');
  }.property('model.lockedBy'),

  saveStateDidChange: function() {
    if (this.get('saveState')) {
      this.setProperties({
        saveStateMessage: 'Saved',
        savedAt: new Date()
      });
    } else {
      this.setProperties({
        saveStateMessage: null,
        savedAt: null
      });
    }
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
