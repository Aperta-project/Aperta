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
    var self = this;
    var toggleHoverClass = function() {
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
    deleteAuthor: function() {
      var self = this;
      this.$().fadeOut(250, function() {
        self.sendAction('delete', self.get('plosAuthor'));
      });
    },

    save: function() {
      this.sendAction('save', this.get('plosAuthor'));
      this.set('editState', false);
    },

    toggleEditForm: function() {
      this.toggleProperty('editState');
    },

    toggleDeleteConfirmation: function() {
      this.toggleProperty('deleteState');
    }
  }
});
