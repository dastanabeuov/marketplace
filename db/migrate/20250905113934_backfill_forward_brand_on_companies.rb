class BackfillForwardBrandOnCompanies < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    Company.unscoped.in_batches(of: 10_000) do |relation|
      relation.where(forward_brand: nil).update_all(forward_brand: false)
      sleep(0.01)
    end
  end

  def down
    # No-op: we don't want to revert the backfill
  end
end
