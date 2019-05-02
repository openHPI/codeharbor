# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FileTypesController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect(get: '/file_types').to route_to('file_types#index')
    end

    it 'routes to #new' do
      expect(get: '/file_types/new').to route_to('file_types#new')
    end

    it 'routes to #show' do
      expect(get: '/file_types/1').to route_to('file_types#show', id: '1')
    end

    it 'routes to #edit' do
      expect(get: '/file_types/1/edit').to route_to('file_types#edit', id: '1')
    end

    it 'routes to #create' do
      expect(post: '/file_types').to route_to('file_types#create')
    end

    it 'routes to #update via PUT' do
      expect(put: '/file_types/1').to route_to('file_types#update', id: '1')
    end

    it 'routes to #update via PATCH' do
      expect(patch: '/file_types/1').to route_to('file_types#update', id: '1')
    end

    it 'routes to #destroy' do
      expect(delete: '/file_types/1').to route_to('file_types#destroy', id: '1')
    end
  end
end
