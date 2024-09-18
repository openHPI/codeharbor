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

    it 'updates the progress bar when changing the title' do
      progress_bar = find('.completeness-checklist-container .progress-bar', visible: :all, wait: true)

      expect do
        find('input', id: 'task_title').set('some title')
        find('body').click # unselect the input to trigger change event
      end.to change { progress_bar['aria-valuenow'] }
    end
  end

  describe '#edit' do
    let(:complete_task) do
      create(:task,
        user:,
        description: 'word ' * 100,
        programming_language: create(:programming_language),
        license: create(:license),
        labels: create_list(:label, 2),
        model_solutions: create_list(:model_solution, 1, :with_content),
        files: create_list(:task_file, 1, :with_text_attachment),
        tests: create_list(:test, 1, :with_content))
    end

    before { visit(edit_task_path(complete_task)) }

    it 'shows a full progress bar' do
      progress_bar = find('.completeness-checklist-container .progress-bar', visible: :all, wait: true)
      sleep(0.2) # wait for task_checklist.coffee to execute
      expect(progress_bar['aria-valuenow']).to eq '100'
    end
  end

  describe '#show' do
    let(:task_owner) { create(:user) }
    let(:task) { create(:task, user: task_owner, access_level: :public) }

    let(:existing_rating_owner) { create(:user) }
    let!(:existing_rating) { create(:rating, task:, user: existing_rating_owner, overall_rating: 3) }

    let(:task_overall_rating_container) { find('.averaged-task-ratings .task-star-rating[data-rating-category=overall_rating]') }

    def displayed_task_rating
      task_overall_rating_container.all('.rating-star.fa-solid.fa-star').size + (task_overall_rating_container.all('.rating-star.fa-regular.fa-star-half-stroke').size / 2.0)
    end

    before { visit(task_path(task)) }

    it 'shows the correct task rating' do
      expect(displayed_task_rating).to eq(existing_rating.overall_rating)
    end

    context 'when submitting a new rating' do
      subject(:rating_submission) do
        find_by_id('ratingModalOpenButton').click

        Rating::CATEGORIES.each do |category|
          first(".task-star-rating[data-rating-category=#{category}][data-is-rating-input=true] .rating-star[data-rating='#{new_rating[category]}']", minimum: 0, wait: false)&.click
        end

        first('#ratingModalSaveButton:not([disabled])', minimum: 0, wait: false)&.click
        wait_for_ajax
      end

      let(:new_rating) { Rating::CATEGORIES.index_with {|_category| 2 } }

      it 'creates a new rating' do
        expect { rating_submission }.to change { Rating.find_by(task:, user:) }.from(nil).to be_a(Rating)
      end

      it 'correctly updates the displayed rating' do
        expect { rating_submission }.to change { displayed_task_rating }.from(existing_rating.overall_rating).to((existing_rating.overall_rating + new_rating[:overall_rating]) / 2.0)
      end

      context 'when trying to submit an incomplete rating' do
        before { new_rating[:overall_rating] = 0 }

        it 'does not create a new rating' do
          expect { rating_submission }.not_to change(Rating, :count)
        end
      end
    end
  end

  describe '#index' do
    before { visit(tasks_path) }

    def select_option(param_name, idx)
      find("#select2-#{param_name}-container").click
      find("#select2-#{param_name}-results :nth-child(#{idx})").click
      find('.search-submit-button-tag').click
    end

    context 'when filtering after min_stars' do
      let!(:good_task) { create(:task, user:, ratings: create_list(:rating, 1, :good)) }

      before { create(:task, user:, ratings: create_list(:rating, 1, :bad)) }

      it 'only shows the good task' do
        find_by_id('advanced', wait: true).click
        select_option('q_min_stars', 3)

        expect(all('.card-task-title').map(&:text)).to contain_exactly(good_task.title)
      end
    end

    context 'when filtering after creation date' do
      let!(:today_task) { create(:task, user:) }
      let!(:last_week_task) { create(:task, user:, created_at: 3.days.ago) }
      let!(:all_time_task) { create(:task, user:, created_at: 1.year.ago) }

      let(:all_time) { 1 }
      let(:today) { 2 }
      let(:last_week) { 3 }

      it 'shows the correct tasks for every setting' do
        find_by_id('advanced', wait: true).click

        select_option('q_created_before_days', all_time)
        expect(all('.card-task-title').map(&:text)).to contain_exactly(today_task.title, last_week_task.title, all_time_task.title)

        select_option('q_created_before_days', last_week)
        expect(all('.card-task-title').map(&:text)).to contain_exactly(today_task.title, last_week_task.title)

        select_option('q_created_before_days', today)
        expect(all('.card-task-title').map(&:text)).to contain_exactly(today_task.title)
      end
    end
  end
end
