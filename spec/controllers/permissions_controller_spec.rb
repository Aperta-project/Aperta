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
require 'support/authorization_spec_helper'

describe PermissionsController do
  include AuthorizationSpecHelper

  let(:user) { FactoryGirl.create :user }
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_production_staff_role
    )
  end
  let!(:paper) { FactoryGirl.create :paper, journal: journal }

  describe '#show' do
    context 'user is not logged' do
      subject(:do_request) { get :show, id: "Paper+#{paper.id}", format: :json }

      it_behaves_like "an unauthenticated json request"
    end

    context 'user logged' do
      before { stub_sign_in(user) }

      context 'has one assignment to the object' do
        let!(:withdraw_permission_for_creator_role) do
          journal.creator_role.ensure_permission_exists(
            :withdraw,
            applies_to: 'Paper',
            states: ['*']
          )
        end

        context 'as the creator' do
          before do
            assign_user user, to: paper, with_role: journal.creator_role
          end

          it 'returns the permission' do
            get :show, id: "Paper+#{paper.id}"
            expect(response.status).to eq(200)
            expect(res_body['permissions'].count).to eq(1)
            first_permission_for = res_body['permissions'][0]['object']
            expect(first_permission_for['id']).to eq(paper.id)
          end
        end
      end

      context 'has one permission at the journal level' do
        let!(:withdraw_permission_for_production_staff_role) do
          journal.production_staff_role.ensure_permission_exists(
            :withdraw,
            applies_to: 'Paper',
            states: ['*']
          )
        end

        context 'as staff' do
          before do
            assign_user(
              user,
              to: paper.journal,
              with_role: journal.production_staff_role
            )
          end

          it 'returns the permission' do
            get :show, id: "Paper+#{paper.id}"
            expect(response.status).to eq(200)
            expect(res_body['permissions'].count).to eq(1)
            first_permission_for = res_body['permissions'][0]['object']
            expect(first_permission_for['id']).to eq(paper.id)
          end
        end
      end
    end
  end
end
