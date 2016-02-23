class MakeListingsLeaseByDefault < ActiveRecord::Migration
  def up
  	change_column :listings, :is_lease, :boolean, :default => true
  end

  def down
  	change_column :listings, :is_lease, :boolean, :default => nil
  end
end
