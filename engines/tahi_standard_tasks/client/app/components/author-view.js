import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

const { computed, on } = Ember;
const { alias } = computed;

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  classNames: ['authors-overlay-item'],
  classNameBindings: ['hoverState:__hover', 'isEditable:__editable'],
  hoverState: false,
  deleteState: false,
  author: alias('model.object'),
  errors: alias('model.validationErrors'),
  errorsPresent: alias('model.errorsPresent'),
  editState: alias('errorsPresent'),

  attachHoverEvent: on('didInsertElement', function() {
    if (this.get('disabled')) { return; }
    const self = this;
    const toggleHoverClass = function() {
      self.toggleProperty('hoverState');
    };

    this.$().hover(toggleHoverClass, toggleHoverClass);
  }),

  teardownHoverEvent: on('willDestroyElement', function() {
    this.$().off('mouseenter mouseleave');
  }),

  dragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.dragItem = this.get('author');
  },

  actions: {
    deleteAuthor() {
      this.$().fadeOut(250, ()=> {
        this.sendAction('delete', this.get('author'));
      });
    },

    save() {
      this.get('model').validateAllKeys();
      if(this.get('errorsPresent')) { return; }

      this.sendAction('save', this.get('author'));
      this.set('editState', false);
    },

    toggleEditForm() {
      this.toggleProperty('editState');
    },

    toggleDeleteConfirmation() {
      this.toggleProperty('deleteState');
    },

    validateField(key, value) {
      this.get('model').validate(key, value);
    }
  }
});
