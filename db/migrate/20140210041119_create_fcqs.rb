class CreateFcqs < ActiveRecord::Migration
  def change
    create_table :fcqs do |t|
      t.integer :yearterm
      t.string :subject
      t.integer :crse
      t.integer :sec
      t.string :instructor_last
      t.string :instructor_first
      t.integer :forms_requested
      t.integer :forms_returned
      t.string :percentage_passed
      t.float :course_overall
      t.float :course_overall_SD
      t.float :instructor_overall
      t.float :instructor_overall_SD
      t.string :total_hours
      t.float :prior_interest
      t.float :effectiveness
      t.float :availability
      t.float :challenge
      t.float :amount_learned
      t.float :respect
      t.string :course_title
      t.string :campus
      t.string :college
      t.string :instructor_group

      t.timestamps
    end
  end
end