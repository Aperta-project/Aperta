import Ember from 'ember';
import DragNDrop from 'tahi/services/drag-n-drop';
import { task as concurrencyTask } from 'ember-concurrency';

const {
  Component,
  computed,
  computed: { alias }
} = Ember;

export default Component.extend(DragNDrop.DraggableMixin, {
  classNameBindings: [
    ':author-task-item',
    'isAuthorCurrentUser:author-task-item-current-user'
  ],
  deleteState: false,
  editing: false,
  author: alias('model.object'),
  componentName: computed('model', function() {
    return this.get('author').constructor
               .toString()
               .match(/group/) ? 'group-author-form' : 'author-form';
  }),

  isAuthorCurrentUser: computed('author.user.id', 'currentUser.id', function() {
    return Ember.isPresent(this.get('author.user.id')) &&
      Ember.isEqual(this.get('author.user.id'), this.get('currentUser.id'));
  }),

  displayName: computed('isAuthorCurrentUser', 'author.displayName', function(){
    let displayName = this.get('author.displayName');
    if(this.get('isAuthorCurrentUser')){
      return `${displayName} (you)`;
    } else {
      return displayName;
    }
  }),

  editState: computed.or('errorsPresent', 'editing'),
  errorsPresent: alias('model.errorsPresent'),

  viewState: computed('editState', 'deleteState', function() {
    return !this.get('editState') && !this.get('deleteState');
  }),

  draggable: computed('isNotEditable', 'editState', function() {
    return !this.get('isNotEditable') && !this.get('editState');
  }),

  loadCard: concurrencyTask( function * () {
    let model = this.get('model.object');
    yield Ember.RSVP.all([
      model.get('card'),
      model.get('answers')
    ]);
  }),

  dragStart(e) {
    e.dataTransfer.effectAllowed = 'move';
    DragNDrop.set('dragItem', this.get('author'));

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

    toggleDeleteConfirmation() {
      this.toggleProperty('deleteState');
    },

    validateField(key, value) {
      this.get('model').validate(key, value);
    }
  }
});
