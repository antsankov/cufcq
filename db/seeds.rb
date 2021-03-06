# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

def fcq_data
  [
    _fcq_a,
    _fcq_b,
    _fcq_c,
    _fcq_d,
    _fcq_e
  ]
end

def all
  {
    'subject' => 'TEST',
    'crse' => 1000,
    'course_title' => 'Test Course',
    'instructor_first' => 'Alejandro',
    'instructor_last' => 'Spina',
    'formsrequested' => 30,
    'formsreturned' => 20,
    'campus' => 'BD',
    'college' => 'AS',
    'activity_type' => 'LEC - Lecture',
    'hours' => '3',
    'n_enroll' => '35',
    'n_incomp' => '0',
    'instr_group' => 'OTH'
  }
end

def _fcq_blank
  data = {
    'yearterm' => 20151,
    'sec' => 6,
    'course_title' => 'Blank Test Course'
  }
  all.merge(data)
end

def _fcq_a
  data = {
    'sec' => 1,
    'yearterm' => 20151,
    'pct_a' => '0.3548387097',
    'pct_b' => '0.4193548387',
    'pct_c' => '0.1935483871',
    'pct_d' => '0.03225806452',
    'pct_f' => '0',
    'n_eot' => '31',
    'avg_grd' => '3.096774194',
    'pct_df' => '0.03225806452',
    'pct_c_minus_or_below' => '0.03225806452',
    'priorinterest' => '4.4',
    'challenge' => '3.7',
    'courseoverall' => '4.5',
    'hoursperwkinclclass' => '7-9',
    'howmuchlearned' => '5.2',
    'instructoroverall' => '6.0',
    'instreffective' => '3.8',
    'instrrespect' => '5.9',
    'availability' => '5.9'
  }
  all.merge(data)
end
def _fcq_b
  data = {
    'sec' => 2,
    'yearterm' => 20147,
    'pct_a' => '0.375',
    'pct_b' => '0.34375',
    'pct_c' => '0.1875',
    'pct_d' => '0.0625',
    'pct_f' => '0.03125',
    'n_eot' => '32',
    'avg_grd' => '2.96875',
    'pct_df' => '0.09375',
    'pct_c_minus_or_below' => '0.09375',
    'priorinterest' => '5.4',
    'challenge' => '3.2',
    'courseoverall' => '4.5',
    'hoursperwkinclclass' => '7-9',
    'howmuchlearned' => '5.4',
    'instructoroverall' => '5.6',
    'instreffective' => '5.8',
    'instrrespect' => '5.9',
    'availability' => '5.7'
  }
  all.merge(data)
end
def _fcq_c
  data = {
    'sec' => 3,
    'yearterm' => 20144,
    'pct_a' => '0.4848484848',
    'pct_b' => '0.303030303',
    'pct_c' => '0.1212121212',
    'pct_d' => '0.06060606061',
    'pct_f' => '0.0303030303',
    'n_eot' => '33',
    'avg_grd' => '3.151515152',
    'pct_df' => '0.09090909091',
    'pct_c_minus_or_below' => '0.09090909091',
    'priorinterest' => '5.4',
    'challenge' => '3.2',
    'courseoverall' => '4.4',
    'hoursperwkinclclass' => '7-9',
    'howmuchlearned' => '5.9',
    'instructoroverall' => '6.0',
    'instreffective' => '4.9',
    'instrrespect' => '6.0',
    'availability' => '6.0'
  }
  all.merge(data)
end
def _fcq_d
  data = {
    'sec' => 4,
    'yearterm' => 20141,
    'pct_a' => '0.5',
    'pct_b' => '0.2647058824',
    'pct_c' => '0.1176470588',
    'pct_d' => '0.08823529412',
    'pct_f' => '0.02941176471',
    'n_eot' => '34',
    'avg_grd' => '3.117647059',
    'pct_df' => '0.1176470588',
    'pct_c_minus_or_below' => '0.1176470588',
    'priorinterest' => '3.4',
    'challenge' => '4.2',
    'courseoverall' => '4.5',
    'hoursperwkinclclass' => '4-6',
    'howmuchlearned' => '5.6',
    'instructoroverall' => '6.0',
    'instreffective' => '5.3',
    'instrrespect' => '6.0',
    'availability' => '5.0'
  }
  all.merge(data)
end
def _fcq_e
  data = {
    'sec' => 5,
    'yearterm' => 20137,
    'pct_a' => '0.5428571429',
    'pct_b' => '0.2',
    'pct_c' => '0.1142857143',
    'pct_d' => '0.08571428571',
    'pct_f' => '0.05714285714',
    'n_eot' => '35',
    'avg_grd' => '3.085714286',
    'pct_df' => '0.1428571429',
    'pct_c_minus_or_below' => '0.1428571429',
    'priorinterest' => '4.1',
    'challenge' => '4.4',
    'courseoverall' => '4.9',
    'hoursperwkinclclass' => '4-6',
    'howmuchlearned' => '5.1',
    'instructoroverall' => '5.7',
    'instreffective' => '5.3',
    'instrrespect' => '5.4',
    'availability' => '4.9'
  }
  all.merge(data)
end

def _course_a
  {
    'course_title' => 'Intro to test courses',
    'subject' => 'TEST',
    'crse' => 1000
  }
end

def _instructor_a
  {
    'instructor_first' => 'Alejandro',
    'instructor_last' => 'Spina'
  }
end

def _department_a
  {
    'name' => 'TEST',
    'long_name' => 'Testing',
    'college' => 'AS',
    'campus' => 'BD'
  }
end

# da main
def main
  # only test environment should be calling db:seed
  return unless Rails.env.test?
  puts 'seed main called'
  fcqs = []
  fcq_data.each do |f|
    fcqs << Fcq.create!(f)
  end
  Fcq.create!(_fcq_blank)
  c = Course.create!(_course_a)
  i = Instructor.create!(_instructor_a)
  d = Department.create!(_department_a)
  fcqs.each do |f|
    c.fcqs << f
    i.fcqs << f
    d.fcqs << f
  end
  c.instructors << i unless c.instructors.exists?(i)
  i.courses << c unless i.courses.exists?(c)
  d.instructors << i unless d.instructors.exists?(i)
  d.courses << c unless d.courses.exists?(c)
  # i.save
  # c.save
  # d.save
  puts 'hstore going'
  i.build_hstore
  c.build_hstore
  d.build_hstore
  puts 'seed finished successfully'
end

# call to main; all data building comes from here
main
