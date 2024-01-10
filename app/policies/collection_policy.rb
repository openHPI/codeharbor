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

  %i[create? show? update? edit? destroy? leave? add_task? remove_task? remove_all? push_collection? download_all?
     share? view_shared?].each do |action|
    define_method(action) { admin? || collection.users.include?(@user) }
  end

  def save_shared?
    Message.received_by(@user).exists?(param_type: 'collection', param_id: collection.id) || admin?
  end
end
