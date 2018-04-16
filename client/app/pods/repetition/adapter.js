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

import ApplicationAdapter from 'tahi/pods/application/adapter';

export default ApplicationAdapter.extend({
  urlForDeleteRecord(id, modelName, snapshot) {
    let options = snapshot.adapterOptions || {};

    if(options.destroyingAll){
      // All repetitions are being destroyed, so do not ask
      // for any updated positions.  This prevents an issue
      // where many repetitions are being destroyed quickly
      // and returning the position for a deleted record will
      // cause an ember 'inflight' error.
      return `/api/repetitions/${id}?destroying_all=true`;
    } else {
      return `/api/repetitions/${id}`;
    }
  }
});
