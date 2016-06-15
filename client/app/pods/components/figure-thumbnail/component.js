import Ember from 'ember';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['destroyState:_destroy', 'editState:_edit'],

  /**
   * @property figure
   * @type {Figure} Ember.Data model instance
   * @default null
   * @required
   */
  figure: null,
  isEditable: null,

  isUploading: false,
  destroyState: false,
  previewState: false,
  editState: false,
  isProcessing: Ember.computed.equal('figure.status', 'processing'),
  showSpinner: Ember.computed.or('isProcessing', 'isUploading'),

  validations: {
    'rank': [{
      type: 'inline',
      message: 'Figure label must be unique',
      validation() {
        let rank = this.get('figure.rank');
        if (rank === 0) { return true; };

        let count = this.get('figure.paper.figures').filterBy('rank', rank).get('length');

        return count === 1;
      }
    }]
  },

  rank: Ember.computed('figure.rank', {
    get() {
      return this.get('figure.rank') || 1;
    },
    set(key, value) {
      this.set('figure.title', `Fig. ${value}`);
      return value;
    }
  }),

  rankErrorMessage: Ember.computed('figure.paper.figures.@each.rank', function() {
    this.validate('rank');
    return this.get('validationErrors.rank');
  }),

  figureIsUnlabeled: Ember.computed.not('figure.rank'),

  unlabeledFigureMessage: `
    Sorry, we didn't find a figure label in this filename.
    Please edit to add a label. `,


  figureUrl: Ember.computed('figure.id', function() {
    return `/api/figures/${this.get('figure.id')}/update_attachment`;
  }),

  onProcessingFinished: Ember.observer('isProcessing', function() {
    if (!this.get('isProcessing')) {
      this.get('processingFinished')();
    }
  }),

  focusOnFirstInput() {
    Ember.run.schedule('afterRender', this, function() {
      this.$('input[type=text]:first').focus();
    });
  },

  actions: {
    cancelEditing() {
      this.set('editState', false);
      this.get('figure').rollback();
    },

    toggleEditState() {
      this.toggleProperty('editState');
      if (this.get('editState')) {
        this.focusOnFirstInput();
      }
    },

    saveFigure() {
      this.get('figure').save();
      this.set('editState', false);
    },

    cancelDestroyFigure() {
      this.set('destroyState', false);
    },

    confirmDestroyFigure() {
      this.set('destroyState', true);
    },

    destroyFigure() {
      this.$().fadeOut(250, ()=> {
        this.get('destroyFigure')(this.get('figure'));
      });
    },

    uploadStarted(data, fileUploadXHR) {
      this.set('isUploading', true);
      this.get('uploadStarted')(data, fileUploadXHR);
    },

    uploadProgress(data) {
      this.get('uploadProgress')(data);
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('uploadFinished')(data, filename);
    },

    toggleStrikingImageFromCheckbox(checkbox) {
      let newValue = null;
      if (checkbox.get('checked')) {
          newValue = checkbox.get('figure.id');
      }
      this.get('strikingImageAction')(newValue);
    }
  }
});
