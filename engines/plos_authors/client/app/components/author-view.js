import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  layoutName: 'components/author-view',
  classNames: ['authors-overlay-item'],
  classNameBindings: ['hoverState:__hover', 'isEditable:__editable'],
  hoverState: false,
  deleteState: false,

  editState: function() {
    return !!this.get('errors');
  }.property('plosAuthor.errors'),

  attachHoverEvent: function() {
    if (this.get('disabled') === true) { return };
    let self = this;
    let toggleHoverClass = function() {
      self.toggleProperty('hoverState');
    };

    this.$().hover(toggleHoverClass, toggleHoverClass);
  }.on('didInsertElement'),

  teardownHoverEvent: function() {
    this.$().off('mouseenter mouseleave');
  }.on('willDestroyElement'),

  dragStart: function(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.dragItem = this.get('plosAuthor');
  },

  actions: {
    deleteAuthor() {
      this.$().fadeOut(250, ()=> {
        this.sendAction('delete', this.get('plosAuthor'));
      });
    },

    save() {
      this.sendAction('save', this.get('plosAuthor'));
      this.set('editState', false);
    },

    toggleEditForm() {
      this.toggleProperty('editState');
    },

    toggleDeleteConfirmation() {
      this.toggleProperty('deleteState');
    }
  }
});
