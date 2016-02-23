class AddHeartsCountToListing < ActiveRecord::Migration
  def change
    add_column :listings, :hearts_count, :integer, :default => 0
  end
end
