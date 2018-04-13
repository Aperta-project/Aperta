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

export default function(type) {

  if ( /\.(jpe?g|png|gif|bmp)$/i.test(type) ) {
    return 'Image';
  }

  if ( /\.(doc|docx)$/i.test(type) ) {
    return 'Word';
  }

  if ( /\.(xls|xlsx)$/i.test(type) ) {
    return 'Excel';
  }

  if ( /\.(ppt|pptx)$/i.test(type) ) {
    return 'Powerpoint';
  }

  if ( /\.(pdf)$/i.test(type) ) {
    return 'PDF';
  }

  if ( /\.(mp4|mpg)$/i.test(type) ) {
    return 'Movie';
  }

  if ( /\.(mp3|flac|wav)$/i.test(type) ) {
    return 'Audio';
  }

  if ( /\.(zip|tar)$/i.test(type) ) {
    return 'Zip';
  }

  if ( /\.(rb|java|py)$/i.test(type) ) {
    return 'Code';
  }

  if ( /\.(txt)$/i.test(type) ) {
    return 'Text';
  }

  if ( /\.(tex)$/i.test(type) ) {
    return 'LaTeX';
  }
}
