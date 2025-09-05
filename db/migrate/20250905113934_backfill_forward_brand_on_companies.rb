class BackfillForwardBrandOnCompanies < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    # Для SQLite используем простое обновление без батчей
    if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'
      Company.unscoped.where(forward_brand: nil).update_all(forward_brand: false)
    else
      # Для других БД используем батчи
      Company.unscoped.in_batches(of: 10_000) do |relation|
        relation.where(forward_brand: nil).update_all(forward_brand: false)
        sleep(0.01)
      end
    end
  end

  def down
    # No-op: we don't want to revert the backfill
  end
end
