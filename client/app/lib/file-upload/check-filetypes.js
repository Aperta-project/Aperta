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

// turns a comma separated list of filetypes into a regex that matches them all
// ".js,.hbs,.txt" => /(js|hbs|txt)$/i
export function filetypeRegex(list){
  let types = list.replace(/\s+|\./g, '').replace(/,/g, '|');
  return new RegExp("\.(" + types + ")$", 'i');
}

export default function(fileName, acceptString) {
  if (Ember.isPresent(acceptString)) {
    let fileTypeMatches = fileName.toLowerCase().match(filetypeRegex(acceptString));
    if (fileName.length && !filetypeRegex(acceptString).test(fileName)) {
      let types = acceptString.split(',').join(' or ');
      return {error: true, msg: `We're sorry, '${fileName}' is not a valid file type. Please upload an acceptable file (${types}).`};
    }
    return {acceptedFileType: fileTypeMatches[0].substr(1), error: false};
  }
}
