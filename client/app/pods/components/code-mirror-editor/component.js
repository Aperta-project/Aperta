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

// https://github.com/IvyApp/ivy-codemirror

import Ember from 'ember';
import LazyLoader from 'tahi/lib/lazy-loader';

export default Ember.Component.extend({
  tagName: 'textarea',

  /**
   * The value of the editor.
   *
   * @property value
   * @type {String}
   * @default null
   */
  value: null,

  lineNumbers: true,
  lineWrapping: true,
  readOnly: false,
  rtlMoveVisually: true,
  theme: 'default',

  /**
   * Force CodeMirror to refresh.
   *
   * @method refresh
   */
  refresh() {
    this.get('codeMirror').refresh();
  },


  // Private

  _editorSetup: Ember.on('didInsertElement', function() {
    this._loadAssets().then(()=> {
      this._initCodemirror();
    });
  }),

  _windowResizeSetup() {
    $(window).on('resize.codemirror', ()=>{
      let height = Math.round(window.innerHeight - $('.CodeMirror').offset().top) - 40;
      this.get('codeMirror').setSize(null, height);
      $('#paper-container .double-pane').css('height', height);
      this.refresh();
    }).resize();
  },

  _windowResizeTeardown: Ember.on('willDestroyElement', function() {
    $(window).off('resize.codemirror');
  }),

  _loadAssets() {
    this._loadCSS();
    return this._loadScripts();
  },

  _loadScripts() {
    let scripts = [
      '/codemirror/codemirror.min.js',
      '/codemirror/mode/stex.js'
    ];

    return LazyLoader.loadScripts(scripts);
  },

  _loadCSS() {
    return LazyLoader.loadCSS('/codemirror/codemirror.css');
  },

  _initCodemirror() {
    let codeMirror = CodeMirror.fromTextArea(this.get('element'), {
      lineNumbers:     this.get('lineNumbers'),
      lineWrapping:    this.get('lineWrapping'),
      readOnly:        this.get('readOnly'),
      rtlMoveVisually: this.get('rtlMoveVisually'),
      theme:           this.get('theme'),
      mode:            this.get('mode')
    });

    // Stash away the CodeMirror instance.
    this.set('codeMirror', codeMirror);

    // Set up handlers for CodeMirror events.
    this._bindCodeMirrorEvent('change', this, '_updateValue');

    // Set up bindings for CodeMirror options.
    this._bindCodeMirrorOption('lineNumbers');
    this._bindCodeMirrorOption('lineWrapping');
    this._bindCodeMirrorOption('readOnly');
    this._bindCodeMirrorOption('rtlMoveVisually');
    this._bindCodeMirrorOption('theme');

    this._bindCodeMirrorProperty('value', this, '_valueDidChange');
    this._valueDidChange();

    // Force a refresh on `becameVisible`, since CodeMirror won't render itself
    // onto a hidden element.
    this.on('becameVisible', this, 'refresh');
    this._windowResizeSetup();
  },

  /**
   * Bind a handler for `event`, to be torn down in `willDestroyElement`.
   *
   * @private
   * @method _bindCodeMirrorEvent
   */
  _bindCodeMirrorEvent(event, target, method) {
    let callback = Ember.run.bind(target, method);

    this.get('codeMirror').on(event, callback);

    this.on('willDestroyElement', this, function() {
      this.get('codeMirror').off(event, callback);
    });
  },

  /**
   * @private
   * @method _bindCodeMirrorProperty
   */
  _bindCodeMirrorOption(key) {
    this._bindCodeMirrorProperty(key, this, '_optionDidChange');

    // Set the initial option synchronously.
    this._optionDidChange(this, key);
  },

  /**
   * Bind an observer on `key`, to be torn down in `willDestroyElement`.
   *
   * @private
   * @method _bindCodeMirrorProperty
   */
  _bindCodeMirrorProperty(key, target, method) {
    this.addObserver(key, target, method);

    this.on('willDestroyElement', this, function() {
      this.removeObserver(key, target, method);
    });
  },

  /**
   * Sync a local option value with CodeMirror.
   *
   * @private
   * @method _optionDidChange
   */
  _optionDidChange(sender, key) {
    this.get('codeMirror').setOption(key, this.get(key));
  },

  /**
   * Update the `value` property when a CodeMirror `change` event occurs.
   *
   * @private
   * @method _updateValue
   */
  _updateValue(instance) {
    this.set('value', instance.getValue());
  },

  _valueDidChange() {
    let codeMirror = this.get('codeMirror'),
        value = this.get('value');

    if (value !== codeMirror.getValue()) {
      codeMirror.setValue(value || '');
    }
  }
});
