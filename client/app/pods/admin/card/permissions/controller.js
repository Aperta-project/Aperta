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

export default Ember.Controller.extend({
  adminCardPermission: Ember.inject.service(),

  actions: {
    turnOnPermission(role, card, permissionAction) {
      const service = this.get('adminCardPermission');
      const cardId = card.get('id');
      const perms = service.addRoleToPermissionSensible(role, cardId, permissionAction);
      Ember.RSVP.all(perms.map((p)=>p.save())).catch(() => {
        // rollbackAttributes does not work with hasMany
        perms.map((p)=>p.get('roles').removeObject(role));
      });
    },

    turnOffPermission(role, card, permissionAction) {
      const service = this.get('adminCardPermission');
      const cardId = card.get('id');
      const perm = service.removeRoleFromPermission(role, cardId, permissionAction);
      perm.save().catch(() => {
        // rollbackAttributes does not work with hasMany
        perm.addObject(role);
      });
    }
  }
});
