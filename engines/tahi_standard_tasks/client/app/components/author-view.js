import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

const {
  Component,
  computed,
  computed: { alias }
} = Ember;

export default Component.extend(DragNDrop.DraggableMixin, {
  classNames: ['author-task-item'],
  deleteState: false,
  author: alias('model.object'),
  componentName: computed('model', function() {
    return this.get('author').constructor
               .toString()
               .match(/group/) ? 'group-author-form' : 'author-form';
  }),

  editState: false,

  viewState: computed('editState', 'deleteState', function() {
    return !this.get('editState') && !this.get('deleteState');
  }),

  draggable: computed('isNotEditable', 'editState', function() {
    return !this.get('isNotEditable') && !this.get('editState');
  }),

  dragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.dragItem = this.get('author');

    // REQUIRED for Firefox to let something drag
    // http://html5doctor.com/native-drag-and-drop
    e.dataTransfer.setData('Text', this.get('author.id'));
  },

  actions: {
    deleteAuthor() {
      this.$().fadeOut(250, ()=> {
        this.sendAction('delete', this.get('author'));
      });
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
