# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RatingsController do
  render_views

  let(:user) { create(:user) }
  let(:task) { create(:task, access_level: :public) }
  let(:rating) { Rating::CATEGORIES.index_with { 5 } }

  let(:valid_attributes) do
    {task_id: task.id, rating:}
  end

  let(:invalid_attributes) do
    {task_id: task, rating: rating.merge(overall_rating: 0)}
  end

  before { sign_in user }

  describe 'POST #create' do
    let(:post_request) { post :create, params: attributes }
    let(:attributes) { valid_attributes }

    shared_examples 'responds with the average_rating of the task' do
      it do
        post_request
        expect(response.body).to eq({average_rating: task.average_rating}.to_json)
      end
    end

    context 'with valid params' do
      it 'creates a new Rating' do
        expect { post_request }.to change(Rating, :count).by(1)
      end

      it 'sets flash message' do
        expect { post_request }.to change { flash[:notice] }.to(I18n.t('common.notices.object_created', model: Rating.model_name.human))
      end

      it_behaves_like 'responds with the average_rating of the task'

      context 'when the user has already rated the task' do
        let!(:existing_rating) { task.ratings.create(user:, overall_rating: 1) }

        it 'updates the existing rating' do
          expect { post_request }.to change { existing_rating.reload.overall_rating }.from(1).to(rating[:overall_rating])
        end

        it 'does not create a new rating' do
          expect { post_request }.not_to change(Rating, :count)
        end

        it 'sets flash message' do
          expect { post_request }.to change { flash[:notice] }.to(I18n.t('common.notices.object_updated', model: Rating.model_name.human))
        end

        it_behaves_like 'responds with the average_rating of the task'
      end

      context 'when user rates his own task' do
        let(:task) { create(:task, user:) }

        it 'does not create a new rating' do
          expect { post_request }.not_to change(Rating, :count)
        end

        it 'sets flash message' do
          expect { post_request }.to change { flash[:alert] }.to(I18n.t('ratings.handle_own_rating.error'))
        end

        it_behaves_like 'responds with the average_rating of the task'
      end
    end

    context 'with invalid params' do
      let(:attributes) { invalid_attributes }

      it 'does not create a new rating' do
        expect { post_request }.not_to change(Rating, :count)
      end

      it_behaves_like 'responds with the average_rating of the task'
    end
  end
end
