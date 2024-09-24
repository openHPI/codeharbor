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

  %i[show? toggle_favorite?].each do |action|
    define_method(action) { admin? || collection.users.include?(@user) || collection.visibility_level_public? }
  end

  %i[create? update? edit? destroy? leave? add_task? remove_task? remove_all? push_collection?
     download_all? share?].each do |action|
    define_method(action) { admin? || collection.users.include?(@user) }
  end

  %i[save_shared? view_shared?].each do |action|
    define_method(action) { Message.received_by(@user).exists?(action: :collection_shared, attachment: collection) || admin? }
  end
end
