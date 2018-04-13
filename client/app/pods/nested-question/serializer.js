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
import DS from 'ember-data';

export default ApplicationSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    children: {embedded: 'always'}
  },

  normalizeRelationships: function(typeClass, hash){
    var payloadKey;

    if (this.keyForRelationship) {
      typeClass.eachRelationship(function(key, relationship) {
        payloadKey = this.keyForRelationship(key, relationship.kind, 'deserialize');
        if(key === payloadKey){
          hash[key] = this.normalizeType(hash[key]);
          return;
        }
        if (!hash.hasOwnProperty(payloadKey)) {
          hash[key] = this.normalizeType(hash[payloadKey]);
          return;
        }

        hash[key] = this.normalizeType(hash[payloadKey]);
        delete hash[payloadKey];
      }, this);
    }
  }

});
