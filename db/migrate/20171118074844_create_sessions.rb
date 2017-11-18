class CreateSessions < ActiveRecord::Migration[5.1]
  def change
    create_table :sessions do |t|
      t.jsonb :context
      t.jsonb :previous_context
      t.references :user
      t.datetime :last_exchange
      t.timestamps
    end
  end
end
