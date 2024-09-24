# frozen_string_literal: true

class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  has_many :group_tasks, dependent: :destroy
  has_many :tasks, through: :group_tasks

  has_many :messages, dependent: :nullify, inverse_of: :attachment

  validates :name, presence: true
  validate :admin_in_group

  def add(user, role: :confirmed_member)
    GroupMembership.new(group: self, user:, role:).save!
  end

  def group_membership_for(user)
    group_memberships.where(user:).first
  end

  def admin?(user)
    admins.include? user
  end

  def confirmed_member?(user)
    confirmed_members.include? user
  end

  def user?(user)
    users.include? user
  end

  def applicant?(user)
    applicants.include? user
  end

  def make_admin(user)
    return false unless confirmed_member?(user)

    group_membership_for(user)&.role_admin!
  end

  def demote_admin(admin)
    return false unless admin?(admin) && admins.size > 1

    group_membership_for(admin)&.role_confirmed_member!
  end

  def grant_access(user)
    return false unless applicant?(user)

    group_membership_for(user)&.role_confirmed_member!
  end

  def admins
    group_memberships.select(&:role_admin?).map(&:user)
  end

  def confirmed_members
    group_memberships.select(&:role_confirmed_member?).map(&:user)
  end

  def applicants
    group_memberships.select(&:role_applicant?).map(&:user)
  end

  def remove_member(user)
    ActiveRecord::Base.transaction do
      group_membership_for(user)&.destroy
      reload
      validate!
    end
  end

  def last_admin?(user)
    group_membership_for(user)&.role_admin? && admins.size == 1
  end

  def to_s
    name
  end

  private

  def admin_in_group
    errors.add(:base, :no_admin) if admins.empty?
  end
end
