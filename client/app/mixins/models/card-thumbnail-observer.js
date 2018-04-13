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

export default Ember.Mixin.create({
  createThumbnail: Ember.on('didCreate', function() {
    const attrs = this.getProperties('completed', 'title', 'paper');
    attrs.taskType = this.get('type');

    const payload = {
      data: {
        id: this.get('id'),
        type: 'card-thumbnail',
        attributes: attrs
      }
    };

    this.store.push(payload);
    this.setThumbnailRelationship();
  }),

  updateThumbnail: Ember.on('didUpdate', function() {
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.set('completed', this.get('completed'));
    }
  }),

  deleteThumbnail: Ember.on('didDelete', function() {
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    if (thumbnail) {
      thumbnail.deleteRecord();
    }
  }),

  upsertThumbnail: Ember.on('didLoad', function() {
    if (this.store.hasRecordForId('card-thumbnail', this.get('id'))) {
      this.updateThumbnail();
    } else {
      this.createThumbnail();
    }

    this.setThumbnailRelationship();
  }),

  setThumbnailRelationship() {
    const thumbnail = this.store.peekRecord('card-thumbnail', this.get('id'));
    this.set('cardThumbnail', thumbnail);
  }
});
