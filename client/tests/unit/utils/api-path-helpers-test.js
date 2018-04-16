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

import { paperDownloadPath } from 'tahi/utils/api-path-helpers';
import { module, test } from 'ember-qunit';

module('Unit | Utility | api path helpers');

test('paperDownloadPath', function(assert) {
  const opts = {
    paperId: 1,
    versionedTextId: 2,
    format: 'pdf'
  };
  assert.equal(
    paperDownloadPath(opts),
    '/api/paper_downloads/1?export_format=pdf&versioned_text_id=2'
  );
});

test('paperDownloadPath', function(assert) {
  const opts = {
    paperId: 1,
    format: 'pdf'
  };
  assert.equal(
    paperDownloadPath(opts),
    '/api/paper_downloads/1?export_format=pdf'
  );
});
