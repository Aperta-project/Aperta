require 'rails_helper'

describe 'routes for resource_proxy' do
  context 'without version' do
    it 'routes to the right things' do
      expect({ get: '/resource_proxy/my_resource/my_token'}).to route_to(
        'controller' => 'resource_proxy',
        'action'     => 'url',
        'resource'   => 'my_resource',
        'token'      => 'my_token'
      )
    end
  end
  context 'with version' do
    it 'routes to the right things' do
      expect({ get: '/resource_proxy/my_resource/my_token/my_version'}).to route_to(
        'controller' => 'resource_proxy',
        'action'     => 'url',
        'resource'   => 'my_resource',
        'token'      => 'my_token',
        'version'    => 'my_version'
      )
    end
  end
end
