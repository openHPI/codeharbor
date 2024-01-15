# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  def collection
    @record
  end

  def index?
    everyone
  end

  def new?
    everyone
  end

  def show?
    admin? || collection.users.include?(@user) || collection.visibility_level_public?
  end

  %i[create? create_ajax? update? edit? destroy? leave? add_task? remove_task? remove_task_ajax? remove_all? push_collection?
     download_all? share?].each do |action|
    define_method(action) { admin? || collection.users.include?(@user) }
  end

  %i[save_shared? view_shared?].each do |action|
    define_method(action) { Message.received_by(@user).exists?(param_type: 'collection', param_id: collection.id) || admin? }
  end
end
