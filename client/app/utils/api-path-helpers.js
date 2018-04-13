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

/**
 * This file functions as a grab bag of routes.
 * Eventually we might want to refactor this into an object but
 * for now top-level functions will do just fine.
 */
export function eligibleUsersPath(taskId, userType) {
  return `/api/tasks/${taskId}/eligible_users/${userType}`;
}

export function filteredUsersPath(paperId) {
  return `/api/filtered_users/users/${paperId}`;
}

export function discussionUsersPath(topicId) {
  return `/api/discussion_topics/${topicId}/users`;
}

export function newDiscussionUsersPath(paperId) {
  return `/api/papers/${paperId}/discussion_topics/new_discussion_users`;
}

export function paperDownloadPath({paperId, versionedTextId, format}) {
  let path = `/api/paper_downloads/${paperId}`;
  let params = {};
  if (format) {
    params.export_format = format;
  }
  if (versionedTextId) {
    params.versioned_text_id = versionedTextId;
  }
  if (!_.isEmpty(params)) {
    path += `?${$.param(params)}`;
  }
  return path;
}

export function similarityCheckReportPath(similarityCheckId) {
  return `/api/similarity_checks/${similarityCheckId}/report_view_only`;
}
