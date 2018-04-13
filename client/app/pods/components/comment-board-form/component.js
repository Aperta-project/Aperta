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
import { PropTypes } from 'ember-prop-types';

const {
  computed,
  Component,
  isEmpty
} = Ember;

export default Component.extend({
  propTypes: {
    participants: PropTypes.array,
    atMentionableStaffUsers: PropTypes.array
  },

  getDefaultProps() {
    return {
      participants: [],
      atMentionableStaffUsers: []
    };
  },

  classNameBindings: ['editing', ':comment-board-form', 'form-group'],
  editing: false,
  comment: '',

  atMentionableUsersUnion: computed.union('participants', 'atMentionableStaffUsers'),

  atMentionableUsers: computed('atMentionableUsersUnion.[]', function() {
    const uniqueUsers = [];
    const currentUsername = this.get('currentUser.username');

    this.get('atMentionableUsersUnion').forEach(function(user) {
      if(!uniqueUsers.isAny('username', user.get('username'))
          && user.get('username') !== currentUsername){
        uniqueUsers.push(user);
      }
    });

    return uniqueUsers;
  }),

  clear() {
    this.set('comment', '');
    this.set('editing', false);
  },

  actions: {
    onChange(value) {
      const action = this.get('onChange');
      if(isEmpty(action)) { return; }
      action(value);
    },

    cancel() {
      this.clear();
      const action = this.get('onCancel');
      if(!isEmpty(action)) { action(); }
    },

    startEditing() {
      this.set('editing', true);
    },

    save() {
      if(isEmpty(this.get('comment'))) {
        return;
      }

      this.get('save')(this.get('comment'));
      this.clear();
    }
  }
});
