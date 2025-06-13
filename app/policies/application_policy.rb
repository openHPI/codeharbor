# frozen_string_literal: true

class ApplicationPolicy
  RESOURCE_ACTIONS = %i[index? create? new? update? edit? destroy?].freeze
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
    require_user! if user_required?
  end

  def method_missing(method_name, *_args)
    if RESOURCE_ACTIONS.include?(method_name)
      Rails.logger.debug { "Pundit policy does not have method #{method_name}. Returning no_one as default." }
      return no_one
    end

    super
  end

  def respond_to_missing?(method_name, include_private = false)
    RESOURCE_ACTIONS.include?(method_name) || super
  end

  private

  def user_required?
    true
  end

  def require_user!
    raise Pundit::NotAuthorizedError.new(I18n.t('common.errors.not_signed_in')) unless @user
  end

  def record_owner?
    @user.present? && @user == @record.user
  end

  def admin?
    @user.present? && @user.role == 'admin'
  end

  def everyone
    # `everyone` here means `every user logged in`
    @user.present?
  end

  def no_one # rubocop:disable Naming/PredicateMethod
    false
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
      require_user!
    end

    def require_user!
      raise Pundit::NotAuthorizedError unless @user
    end
    private :require_user!
  end
end
