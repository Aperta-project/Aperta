import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

const { computed, on } = Ember;
const { alias } = computed;

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  classNames: ['authors-overlay-item'],
  classNameBindings: ['showHover:__hover', 'isEditable:__editable'],

  author: alias('model.object'),
  errors: alias('model.validationErrors'),
  errorsPresent: alias('model.errorsPresent'),
  editState: alias('errorsPresent'),

  fieldsDisabled: Ember.computed.alias('isEditable'),

  // canHover is true, now, but should be Ember.computed.alias('isEditable')
  // once the read-only author-view contains all needed information.
  canHover: true,
  isHovering: false,
  showHover: Ember.computed.and('isHovering', 'canHover'),

  _setupHover: Ember.on('didInsertElement', function(){
    this.$().hover(() => {
      this.toggleProperty('isHovering');
    });
  }),

  _destroyHover: Ember.on('willDestroyElement', function(){
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
