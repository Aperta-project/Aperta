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

import ApplicationSerializer from 'tahi/pods/application/serializer';
import Ember from 'ember';

export default ApplicationSerializer.extend({
  /**
   * We demodulize Ruby classes in Aperta when they're sent to Ember. This happens
   * in the application serializer on the ember side, at least for models with a 'type'
   * attribute on them.  We save the original (namespaced) class name into a 'qualifiedType'
   * attribute that you can find on any of the Task subclasses if you look in the ember data store.
   * We also demodulize any classnames when they're included as part of a polymorphic relationship.
   * ie {owner: {type: 'TahiStandardTasks::CompetingInterestTask', id: 2} becomes
   *    {owner: {type: 'CompetingInterestTask', id: 2}.
   *
   * That's fine for the read-only case; ember uses the type and id information
   * to look up a record in the store.  If we want to save the relationship info back to the api,
   * though, we have to have the fully namespaced class name.
   *
   * We've chosen to do this by looking for an ownerTypeForAnswer method on the Answerable module,
   * which we refer to below.
   */
  serializePolymorphicType: function(snapshot, json, relationship) {
    let key = relationship.key;
    let belongsTo = snapshot.belongsTo(key);
    key = this.keyForAttribute ? this.keyForAttribute(key, 'serialize') : key;

    if (Ember.isNone(belongsTo)) {
      json[key + '_type'] = null;
    } else {
      json[key + '_type'] = belongsTo.attr('ownerTypeForAnswer');
    }
  }
});
