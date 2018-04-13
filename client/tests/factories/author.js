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

import FactoryGuy from "ember-data-factory-guy";

FactoryGuy.define("author", {
  default: {
    paper: FactoryGuy.belongsTo("paper"),
    task: {},

    first_name: "Adam",
    position: 1,

    nestedQuestions: [
      {id: 911, ident: 'author--published_as_corresponding_author'},
      {id: 912, ident: 'author--deceased'},
      {id: 913, ident: 'author--contributions--conceptualization'},
      {id: 914, ident: 'author--contributions--conceptualization'},
      {id: 915, ident: 'author--contributions--investigation'},
      {id: 916, ident: 'author--contributions--visualization'},
      {id: 917, ident: 'author--contributions--methodology'},
      {id: 919, ident: 'author--contributions--resources'},
      {id: 920, ident: 'author--contributions--supervision'},
      {id: 921, ident: 'author--contributions--software'},
      {id: 922, ident: 'author--contributions--data-curation'},
      {id: 923, ident: 'author--contributions--project-administration'},
      {id: 924, ident: 'author--contributions--validation'},
      {id: 925, ident: 'author--contributions--writing-original-draft'},
      {id: 926, ident: 'author--contributions--writing-review-and-editing'},
      {id: 927, ident: 'author--contributions--funding-acquisition'},
      {id: 928, ident: 'author--contributions--formal-analysis'},
      {id: 929, ident: 'author--government-employee'}
    ]
  }
});
