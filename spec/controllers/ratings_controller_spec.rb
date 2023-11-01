# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingsController do
  render_views

  let(:user) { create(:user) }
  let(:task) { create(:task) }
  let(:rating) { 4 }

  let(:valid_attributes) do
    {task_id: task.id, rating: {rating:}}
  end

  let(:invalid_attributes) do
    {task_id: task, rating: {rating: 0}}
  end

  before { sign_in user }

  describe 'POST #create' do
    let(:post_request) { post :create, params: attributes }
    let(:attributes) { valid_attributes }

    render_views
    context 'with valid params' do
      it 'creates a new Rating' do
        expect { post_request }.to change(Rating, :count).by(1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('ratings.handle_rating.rating_created'))
      end

      it 'responds with overall_rating and user_rating' do
        post_request
        expect(response.body).to include('overall_rating').and(include('user_rating'))
      end

      context 'when the user has already rated the task' do
        let!(:existing_rating) { task.ratings.create(user:, rating: 1) }

        it 'updates the existing rating' do
          expect { post_request }.to change { existing_rating.reload.rating }.from(1).to(rating)
        end

        it 'does not create a new rating' do
          expect { post_request }.not_to change(Rating, :count)
        end

        it 'sets flash message' do
          expect { post_request }.to change { flash[:notice] }.to(I18n.t('ratings.handle_rating.rating_updated'))
        end

        it 'responds with overall_rating and user_rating' do
          post_request
          expect(response.body).to include('overall_rating').and(include('user_rating'))
        end
      end

      context 'when user rates his own task' do
        let(:task) { create(:task, user:) }

        it 'does not create a new rating' do
          expect { post_request }.not_to change(Rating, :count)
        end

        it 'sets flash message' do
          expect { post_request }.to change { flash[:alert] }.to(I18n.t('ratings.handle_own_rating.error'))
        end

        it 'responds with overall_rating and user_rating' do
          post_request
          expect(response.body).to include('overall_rating').and(include('user_rating'))
        end
      end
    end

    context 'with invalid params' do
      let(:attributes) { invalid_attributes }

      it 'does not create a new rating' do
        expect { post_request }.not_to change(Rating, :count)
      end

      it 'responds with error' do
        post_request
        expect(response.body).to include(I18n.t('common.errors.generic'))
      end
    end
  end
end
