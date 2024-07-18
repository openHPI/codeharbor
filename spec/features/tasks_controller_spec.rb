# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'TasksController', :js do
  let(:user) { create(:user) }
  let(:password) { attributes_for(:user)[:password] }

  before do
    sign_in_with_js_driver(user, password)
  end

  describe '#new' do
    before { visit(new_task_path) }

    context 'with invalid params' do
      let(:not_existing_label_name) { 'some new label' }

      it 'displays labels after invalid submission attempt' do
        input = find('select', id: 'task_label_names').sibling('span', class: 'select2').find('textarea')
        input.click # Open select2 dropdown, set focus
        input.send_keys(not_existing_label_name) # Enter label name
        # Assert the label is showing up as a search result. This will implicitly wait for the search (and AJAX calls) to complete.
        expect(page).to have_css('div.task_label', text: not_existing_label_name, visible: :all)
        input.send_keys(:enter) # Select the first option.
        input.click # Close select2 dropdown
        # Assert the label is showing up as a selected label. This will implicitly wait, too.
        expect(page).to have_css("ul li[title=\"#{not_existing_label_name}\"", visible: :all)
        click_on(I18n.t('tasks.form.button.save_task'))
        expect(page).to have_css("option[value=\"#{not_existing_label_name}\"][selected=\"selected\"]", visible: :all)
      end
    end
  end

  describe '#show' do
    let(:task_owner) { create(:user) }
    let(:task) { create(:task, user: task_owner, access_level: :public) }

    let(:rating_owner) { create(:user) }
    let!(:rating) { create(:rating, task:, user: rating_owner, overall_rating: 4) }
    let!(:another_rating) { create(:rating, task:, user: create(:user), overall_rating: 3) }

    let(:task_overall_rating_container) { find('.averaged-task-ratings .task-star-rating[data-rating-category=overall_rating]') }
    let(:displayed_task_rating) { task_overall_rating_container.all('.rating-star.fa-solid.fa-star').size + (task_overall_rating_container.all('.rating-star.fa-regular.fa-star-half-stroke').size / 2) }

    before { visit(task_path(task)) }

    it 'shows the correct task rating' do
      expect(displayed_task_rating).to eq((rating.overall_rating + another_rating.overall_rating) / 2)
    end

    context 'when submitting a new rating' do
      let(:new_rating) { 2 }

      before do
        find_by_id('ratingModalOpenButton').click

        find(".task-star-rating[data-rating-category=overall_rating][data-is-rating-input=true] .rating-star[data-rating='#{new_rating}']").hover

        find_by_id('ratingModalSaveButton').click
      end

      it 'correctly updates the displayed rating' do
        expect(displayed_task_rating).to eq((rating.overall_rating + another_rating.overall_rating + new_rating) / 3)
      end
    end
  end
end
