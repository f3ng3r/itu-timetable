class CreateTimetables < ActiveRecord::Migration
  def change
    create_table :timetables do |t|
      t.string :itu_email
      t.text :courses

      t.timestamps
    end
  end
end
