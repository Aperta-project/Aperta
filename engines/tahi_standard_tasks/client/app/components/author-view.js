import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';

export default Ember.Component.extend(DragNDrop.DraggableMixin, {
  layoutName: 'components/author-view',
  classNames: ['authors-overlay-item'],
  classNameBindings: ['showHover:__hover', 'isEditable:__editable'],


  editState: function() {
    return !!this.get('errors');
  }.property('author.errors'),

  canHover: Ember.computed.alias('isEditable'),
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

  dragStart: function(e) {
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
      this.sendAction('save', this.get('author'));
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
