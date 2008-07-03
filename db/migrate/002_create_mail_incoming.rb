class CreateMailIncoming < ActiveRecord::Migration
  def self.up
    create_table :mail_incoming do |t|
      t.text :mail
      t.datetime :created_on
    end
  end

  def self.down
    drop_table :mail_incoming
  end
end
