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
