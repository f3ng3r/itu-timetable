class AddIndexToItuEmail < ActiveRecord::Migration
  def change
    add_index(:timetables, :itu_email)
  end
end
