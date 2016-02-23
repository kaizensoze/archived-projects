class AddClosingAgentIdAndLandlordCommissionAndTenantCommissionAndAgentCutAndBonusCutAndListinCutAndCobrokerCutAndNooklynCutToDeals < ActiveRecord::Migration
  def change
    add_column :deals, :closing_agent_id, :integer
    add_column :deals, :landlord_commission, :float
    add_column :deals, :tenant_commission, :float
    add_column :deals, :agent_cut, :float
    add_column :deals, :bonus_cut, :float
    add_column :deals, :listing_cut, :float
    add_column :deals, :cobroker_cut, :float
    add_column :deals, :nooklyn_cut, :float
  end
end
