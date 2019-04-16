# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/carts').to route_to('carts#index')
    end

    it 'routes to #new' do
      expect(get: '/carts/new').to route_to('carts#new')
    end

    it 'routes to #show' do
      expect(get: '/carts/1').to route_to('carts#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/carts/1/edit').to route_to('carts#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/carts').to route_to('carts#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/carts/1').to route_to('carts#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/carts/1').to route_to('carts#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/carts/1').to route_to('carts#destroy', id: '1')
    end
  end
end
