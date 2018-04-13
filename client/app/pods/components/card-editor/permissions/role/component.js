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
import { permissionExists } from 'tahi/lib/admin-card-permission';

export default Ember.Component.extend({
  propTypes: {
    card: PropTypes.EmberObject.isRequired,
    role: PropTypes.EmberObject.isRequired,
    turnOnPermission: PropTypes.func.isRequired,
    turnOffPermission: PropTypes.func.isRequired
  },

  tagName: 'tr',

  viewAllowed: permissionExists('card', 'role', 'view'),
  editAllowed: permissionExists('card', 'role', 'edit'),
  view_discussion_footerAllowed: permissionExists('card', 'role', 'view_discussion_footer'),
  edit_discussion_footerAllowed: permissionExists('card', 'role', 'edit_discussion_footer'),
  be_assignedAllowed: permissionExists('card', 'role', 'be_assigned'),
  assign_othersAllowed: permissionExists('card', 'role', 'assign_others'),
  view_participantsAllowed: permissionExists('card', 'role', 'view_participants'),
  manage_participantAllowed: permissionExists('card', 'role', 'manage_participant'),
  actions: {
    togglePermission(permissionAction) {
      if (this.get(`${permissionAction}Allowed`)) {
        this.get('turnOffPermission')(this.get('role'), this.get('card'), permissionAction);
      } else {
        this.get('turnOnPermission')(this.get('role'), this.get('card'), permissionAction);
      }
    }
  }
});
