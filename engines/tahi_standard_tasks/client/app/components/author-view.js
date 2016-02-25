import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

const { computed, on } = Ember;
const { alias, not } = computed;

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  classNames: ['author-task-item'],
  deleteState: false,
  author: alias('model.object'),
  errors: alias('model.validationErrors'),
  errorsPresent: alias('model.errorsPresent'),
  editState: alias('errorsPresent'),
  viewState: computed('editState', 'deleteState', function() {
    return !this.get('editState') && !this.get('deleteState');
  }),
  draggable: computed('isNotEditable', 'editState', function() {
    return !this.get('isNotEditable') && !this.get('editState');
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
