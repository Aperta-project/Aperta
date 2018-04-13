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
import config from 'tahi/config/environment';

const Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: config.rootURL
});

Router.map(function() {
  this.route('invitations', { path: '/invitations/:token' });
  this.route('coauthors', { path: '/co_authors_token/:token' });

  this.route('dashboard', { path: '/' }, function() {});

  this.route('paper_tracker', function() {});

  this.route('paper', { path: '/papers/:paper_shortDoi' }, function() {
    this.route('index', { path: '/' }, function() {
      this.route('discussions', function() {
        this.route('new',  { path: '/new' });
        this.route('show', { path: '/:topic_id' });
      });
    });

    this.route('versions', { path: '/versions' });

    this.route('correspondence', { path: '/correspondence' }, function() {
      this.route('edit', { path: '/:correspondence_id/edit' });
      this.route('delete', { path: '/:correspondence_id/delete' });
      this.route('viewcorrespondence',  { path: '/viewcorrespondence/:id' });
      this.route('new', { path: '/new' });
      this.route('discussions', function() {
        this.route('new',  { path: '/new' });
        this.route('show', { path: '/:topic_id' });
      });
    });


    this.route('workflow', function() {
      this.route('discussions', function() {
        this.route('new',  { path: '/new' });
        this.route('show', { path: '/:topic_id' });
      });
    });

    this.route('task', { path: '/tasks' }, function() {
      this.route('index', { path: '/:task_id' });
      this.route('version', { path: '/:task_id/version' });
    });
    this.route('submit');
  });

  this.route('discussions', function() {
    this.route('paper', {path: '/:paper_shortDoi'}, function() {
      this.route('index', {path: '/'});
      this.route('new', { path: '/new'});
      this.route('show', { path: '/:topic_id' });
    });
  });

  this.route('profile', { path: '/profile' });

  this.route('admin', function() {
    this.route('journals', { path: '/journals/:journal_id' }, function() {
      this.route('cards');
      this.route('workflows');
      this.route('users');
      this.route('settings');
      this.route('emailtemplates');
    });
    this.route('card', { path: '/card/:card_id' }, function() {
      this.route('preview', { path: '/' });
      this.route('edit');
      this.route('permissions');
      this.route('history');
    });
    this.route('edit_email', { path: 'journals/emailtemplates/:email_id/edit' });
    this.route('mmt', function() {
      this.route('journal', { path: '/journals/:journal_id' }, function() {
        this.route('manuscript_manager_template', { path: '/manuscript_manager_templates' }, function() {
          this.route('new');
          this.route('edit', { path: '/:manuscript_manager_template_id/edit' });
        });
      });
    });
    this.route('feature_flags');
  });
});

export default Router;
