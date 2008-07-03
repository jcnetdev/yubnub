class CreateMailOutgoing < ActiveRecord::Migration
  def self.up
    create_table :mail_outgoing do |t|
      t.string :from
      t.string :to
      t.integer :last_send_attempt, :default => 0
      t.text :mail
      t.datetime :created_on
    end
  end

  def self.down
    drop_table :mail_outgoing
  end
end
