class RenameAccountLinksUsersToAccountLinkUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table 'account_links_users', 'account_link_users'
  end
end
