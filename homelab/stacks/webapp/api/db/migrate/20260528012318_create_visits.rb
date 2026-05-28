class CreateVisits < ActiveRecord::Migration[8.1]
  def change
    create_table :visits do |t|
      t.string :ip_address
      t.string :user_agent
      t.string :referer
      t.string :path
      t.string :accept_language
      t.string :country
      t.string :region
      t.string :city
      t.string :org
      t.string :browser
      t.string :os
      t.string :device_type

      t.timestamps
    end
  end
end
