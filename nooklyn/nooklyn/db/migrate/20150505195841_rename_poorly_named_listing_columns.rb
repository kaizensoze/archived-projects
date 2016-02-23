class RenamePoorlyNamedListingColumns < ActiveRecord::Migration
  def change
    rename_column :listings, :available, :date_available
    rename_column :listings, :is_residential, :residential
    rename_column :listings, :is_lease, :rental
    rename_column :listings, :is_exclusive, :exclusive
    rename_column :listings, :is_featured, :featured
  end
end
