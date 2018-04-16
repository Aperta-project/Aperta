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

export default Ember.Component.extend({
  relatedArticle: null, // Pass me in, please
  editable: true,       // Pass me in, please

  classNames: ['related-article'],
  classNameBindings: ['editable', 'editState:editing', 'idClass'],

  idClass: Ember.computed('relatedArticle.id', function() {
    return 'related-article-' + this.get('relatedArticle.id');
  }),

  editState: Ember.computed('relatedArticle.isNew', function() {
    return this.get('relatedArticle.isNew');
  }),

  actions: {
    titleChanged: function (contents) {
      this.set('relatedArticle.linkedTitle', contents);
    },

    infoChanged: function (contents) {
      this.set('relatedArticle.additionalInfo', contents);
    },

    edit: function() {
      this.set('editState', true);
    },

    cancelEdit: function() {
      this.get('relatedArticle').rollbackAttributes();
      this.set('editState', false);
    },

    save: function() {
      this.get('relatedArticle').save();
      this.set('editState', false);
    },

    delete: function() {
      this.get('relatedArticle').destroyRecord();
    }
  }
});
