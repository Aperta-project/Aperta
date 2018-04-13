/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';
import DragNDrop from 'tahi/pods/drag-n-drop/service';

const {
  Component,
  computed,
  computed: { alias, readOnly }
} = Ember;

export default Component.extend(DragNDrop.DraggableMixin, {
  classNameBindings: [
    ':author-task-item',
    'isAuthorCurrentUser:author-task-item-current-user'
  ],
  deleteState: false,

  author: alias('model.object'),
  journal: alias('author.paper.journal'),
  coauthorConfirmationEnabled: readOnly('journal.coauthorConfirmationEnabled'),

  componentName: computed('model', function() {
    return this.get('author').get('constructor.modelName').toString()
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
  editing: false,
  errorsPresent: alias('model.errorsPresent'),

  viewState: computed('editState', 'deleteState', function() {
    return !this.get('editState') && !this.get('deleteState');
  }),

  draggable: computed('isNotEditable', 'editState', function() {
    return !this.get('isNotEditable') && !this.get('editState');
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

    toggleEditForm() {
      this.toggleProperty('editing');
    },

    toggleDeleteConfirmation() {
      this.toggleProperty('deleteState');
    },

    validateField(key, value) {
      this.get('model').validate(key, value);
    }
  }
});
