# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe 'routes for resource_proxy' do
  describe 'legacy resource_proxy routes' do
    let(:resources) { %w(adhoc_attachments question_attachments attachments figures supporting_information_files) }

    context 'without version' do
      it 'routes to the resource proxy for each whitelisted resource' do
        resources.each do |resource|
          expect(get: "/resource_proxy/#{resource}/my_token").to route_to(
            'controller' => 'resource_proxy',
            'action'     => 'url',
            'resource'   => resource,
            'token'      => 'my_token'
          )
        end
      end
    end

    context 'with version' do
      it 'routes to attachment version for each whitelisted resource' do
        resources.each do |resource|
          expect(get: "/resource_proxy/#{resource}/my_token/my_version").to route_to(
            'controller' => 'resource_proxy',
            'action'     => 'url',
            'resource'   => resource,
            'token'      => 'my_token',
            'version'    => 'my_version'
          )
        end
      end
    end
  end

  describe 'token only resource proxy routes' do
    it 'routes to resource proxy when only given a token' do
      expect(get: '/resource_proxy/my_token').to route_to(
        'controller' => 'resource_proxy',
        'action'     => 'url',
        'token'      => 'my_token'
      )
    end
  end
end
