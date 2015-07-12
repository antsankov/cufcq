#lib/tasks/import.rake
# to call, run
require 'csv'

# lib/tasks/kill_postgres_connections.rake
task :kill_postgres_connections => :environment do
  db_name = "#{File.basename(Rails.root)}_#{Rails.env}"
  sh = <<EOF
ps xa \
  | grep postgres: \
  | grep #{db_name} \
  | grep -v grep \
  | awk '{print $1}' \
  | xargs kill
EOF
  puts `#{sh}`
end

#require "#{Rails.root}/app/helpers/fcqs_helper.rb"
desc "Imports FCQ CSV file into an ActiveRecord table"
task :import => :environment do
  puts 'starting import'
  Dir.glob('data/fcq/fcq.*.csv').each do |csv|
    puts "loading csv file: " + csv
    CSV.foreach(csv, :headers => true) do |row|
      begin
        h = row.to_hash
        # does a number of operations to split an instructor name into a first and last name
        name = h['instructor'] || ','
        i_name = name.split(', ') || ['', '']
        h['instructor_first'] = i_name[1] || ''
        h['instructor_last'] = i_name[0] || ''
        h['instructor_first'].capitalize!
        h['instructor_last'].capitalize!
        h['course_title'] = h['crstitle']
        h.select! { |k, _v| Fcq.column_names.include? k }
        puts 'creating a new fcq'
        f = Fcq.create!(h)
        puts 'finished rceating annew fcqS'
        # puts f.fcq_object
        # given a new fcq object, create the instructor and course
        i_params = {'instructor_first' => f.instructor_first, "instructor_last" => f.instructor_last}
        c_params = {'course_title' => f.course_title, "crse" => f.crse, "subject" => f.subject}
        # fix for the phil1400 bug
        c_abridged_params = { 'crse' => f.crse, 'subject' => f.subject }
        d_params = { 'name' => f.subject }
        c = Course.where(c_abridged_params).first || Course.create!(c_params)
        i = Instructor.where(i_params).first || Instructor.create!(i_params)
        d = Department.where(d_params).first || Department.create!(d_params)
        i.fcqs << f
        c.fcqs << f
        d.fcqs << f
        c.instructors << i unless c.instructors.exists?(i)
        i.courses << c unless i.courses.exists?(c)
        d.instructors << i unless d.instructors.exists?(i)
        d.courses << c unless d.courses.exists?(c)
      rescue ActiveRecord::RecordInvalid => invalid
        puts invalid.message
        next
      rescue ActiveRecord::RecordNotUnique => unique
        puts unique.message
        next
      rescue ActiveRecord::UnknownAttributeError => unknown
        puts unknown.message
        next
      end
    end
  end
  puts 'Finished Importing FCQ CSV'
end
# task :import => :environment do
#   puts "start"
#   Dir.glob('data/output/*.csv').each do |csv|
#     puts "loading csv file: " + csv
#     CSV.foreach(csv, :headers => true) do |row|
#       begin
#           #puts row.to_hash
#           #h = row.to_hash.select {|k,v| k == "instructor_first" || "k == instructor_last"}
#           #inst = get_instructor(params)
#           #inst.fcqs.create!(row.to_hash)
#       f = Fcq.create!(row.to_hash)
#       puts f.fcq_object
#       rescue ActiveRecord::RecordInvalid => invalid
#           puts invalid.message
#           next
#       rescue ActiveRecord::RecordNotUnique => unique
#         next
#       rescue ActiveRecord::UnknownAttributeError => unknown
#         puts unknown.message
#         next
#       end
#     end
#   end
#   puts "finish"
# end

task :drop_tables => :environment do
  drop_table :departments
  drop_table :instructors
  drop_table :courses
end


task :department_populate => :environment do
  puts "Departmet populate"
  Fcq.find_each(:batch_size => 200) do |x|
    begin
      params = {"name" => x.subject, "college" => x.college, "campus" => x.campus}
      i = Department.create!(params)

      puts i
    rescue StandardError => e
        puts "rescued -" + e.message
    end
      i = i.nil? ? Department.where(params).first : i
      #puts i
      i.fcqs << x unless (i.fcqs.exists?(x))
      puts i.id + x.id
    end
    puts "Finished Department populate"
end

# builds the hstore information for the departments. This is the data that is cached for the department.
# This prevents a department page from having to reload large quanitites of information every time it wants to render a graph
task :department_build_hstore => :environment do
  puts "Building Department Hstore"
  Department.find_each(:batch_size => 200) do |x|
    begin
      x.build_hstore
    #   puts "build #{x.name} hstore"
    # rescue StandardError => e
    #     puts "rescued -" + e.message
    end
  end
  puts "Finsihed Building Department Hstore"

end

task :instructor_build_hstore => :environment do
  puts "Building Instructor Hstore"
  Instructor.find_each(:batch_size => 200) do |x|
    begin
      x.build_hstore
    #   puts "build #{x.name} hstore"
    rescue StandardError => e
        puts "rescued -" + e.message
    end
  end
  puts "Finsihed Building Instructor Hstore"
end

task :course_build_hstore => :environment do
  puts "Building Course Hstore"
  Course.find_each(:batch_size => 200) do |x|
    begin
      x.build_hstore
      puts "build #{x.course_title} hstore"
    rescue StandardError => e
        puts "rescued -" + e.message
    end
  end
  puts "Finished Building Course Hstore"
end

task :build_data => :environment do
  puts 'building all of the datas'
  total = Fcq.count
  puts "#{total} total Fcqs"
  x = 0
  errors = []
  Fcq.find_each(:batch_size => 200) do |f|
    begin
      x += 1
      c = f.course
      d = f.department
      i = f.instructor
      c.instructors << i unless c.instructors.exists?(i)
      i.courses << c unless i.courses.exists?(c)
      d.instructors << i unless d.instructors.exists?(i)
      d.courses << c unless d.courses.exists?(c)
      puts "#{total} / #{x}"
    rescue NoMethodError => e
      begin
      puts "NoMethodError #{e}"
      puts "caught for fcq #{f.id}"
      # puts f.fcq_object
      # given a new fcq object, create the instructor and course
      i_params = {'instructor_first' => f.instructor_first, "instructor_last" => f.instructor_last}
      c_params = {'course_title' => f.course_title, "crse" => f.crse, "subject" => f.subject}
      # fix for the phil1400 bug
      c_abridged_params = { 'crse' => f.crse, 'subject' => f.subject }
      d_params = { 'name' => f.subject }
      c = Course.where(c_abridged_params).first || Course.create!(c_params)
      i = Instructor.where(i_params).first || Instructor.create!(i_params)
      d = Department.where(d_params).first || Department.create!(d_params)
      i.fcqs << f
      c.fcqs << f
      d.fcqs << f
      retry
      rescue StandardError => e
        errors << f.id
        next
      end
    # rescue StandardError => e
    #   puts "rescued -" + e.message
    end
  end
  puts 'finished building all of the datas'
  puts 'errors at'
  errors.each do |e|
    puts "#{e}"
  end

end



task :instructor_populate => :environment do
  puts "Instructor Populate"
  Fcq.find_each(:batch_size => 200) do |x|
    begin
      params = {"instructor_first" => x.instructor_first, "instructor_last" => x.instructor_last}
      i = Instructor.create!(params)
      # puts i
      rescue StandardError => e
        puts "rescued -" + e.message
    end
      i = i.nil? ? Instructor.where(params).first : i
      i.fcqs << x  unless (i.fcqs.exists?(x))
      # puts i.id + x.id
    end
    puts "Finsihed Instructor Populate"
end


# task :instructor_rake => :environment do
#   Fcq.find_each(:batch_size => 200) do |f|
#     begin
#       f.instructor
#       params = {"instructor_first" => x.instructor_first, "instructor_last" => x.instructor_last}
#       i = Instructor.create!(params)
#       puts i
#       rescue StandardError => e
#         puts "rescued -" + e.message
#     end
#       i = i.nil? ? Instructor.where(params).first : i
#       i.fcqs << x  unless (i.fcqs.exists?(x))
#       puts i.id + x.id
#     end
# end


task :course_populate => :environment do
  puts "Course Populate"
  Fcq.find_each(:batch_size => 200) do |x|
    begin
      if x.recitation?
        next
      end
      params = {"course_title" => x.course_title, "crse" => x.crse, "subject" => x.subject}
      title = x.course_title
      sec = x.sec
      i = Course.create!(params)
      rescue StandardError => e
        puts "rescued -" + e.inspect
    end
    #   puts params
      i = i.nil? ? Course.where(params).first : i
      i.fcqs << x  unless (i.fcqs.exists?(x))
    #   puts i.id + x.id
    end
  #recitation correction
  Fcq.find_each(:batch_size => 200) do |x|
  begin
    unless x.recitation?
      next
    end
    params = {"course_title" => x.course_title, "crse" => x.crse, "subject" => x.subject}
    i = Course.where(params).first
    if i.nil?
      next
    end
    i.fcqs << x
    # puts i.id + x.id
   rescue StandardError => e
     puts "rescued -" + e.inspect
   end
 end
 puts "Finished Course Populate"
end

task :ic_relations => :environment do
  puts "IC Relations"
  Fcq.find_each do |f|
    begin
        instr_params = {"instructor_last" => f.instructor_last , "instructor_first" => f.instructor}
        crse_params = {"crse" => f.crse, "subject" => f.subject}
        dep_params = {"name" => f.subject, "college" => f.college, "campus" => f.campus}
        c = Course.where(params).first
        d = Department.where(dep_params).first
        d = Department.where(dep_params).first
        if c.nil?
          next
        elsif d.nil?
          next
        end
        if f.course.nil?
          c.fcqs << f
        end
        c.instructors << i unless c.instructors.exists?(i)
        # puts "added " + i.full_name.to_s + " to " + c.course_title.to_s
        i.courses << c unless i.courses.exists?(c)
        # puts "added " + c.course_title.to_s + " to " + i.full_name.to_s
        d.instructors << i unless d.instructors.exists?(i)
        # puts "added " + i.full_name.to_s + " to " + d.name.to_s
        d.courses << c unless d.courses.exists?(c)
        # puts "added " + c.course_title.to_s + " to " + d.name.to_s

        # puts "#{c.course_title}  <->  #{i.name.to_s}"
      # puts c.instructors

      rescue ActiveRecord::RecordInvalid => e
        #puts "skipping invalid record, this is intentional"
      rescue ActiveRecord::AssociationTypeMismatch => e
        puts "association mismatch error, this means courses are having a hard time being found/associated. This is bad"
      #end
      rescue StandardError => e
        puts "rescued -" + e.inspect
      end
    end
    puts  "Finsihed IC Relations"

end

# LONG_NAMES = {"CSCI" => "Computer Science", "MATH" => "Mathematics", "PHIL" => "Philosophy", "APPM" => "Applied Mathematics", "CHEN" => "Chemical Engineering"}
# task :set_department_name => :environment do
#     puts "Setting Department Long Names"
#     puts "For every Department code, Enter it's long name, eg"
#   Department.find_each do |d|
#     begin
#       print d.name + ": "
#       if LONG_NAMES.include?(d.name)
#         Department.update(d.id, :long_name => LONG_NAMES[d.name])
#         print LONG_NAMES[d.name]
#         puts ""
#         next
#       end
#       ln = STDIN.gets.chomp
#       puts ""
#       #puts d.update_attribute(:long_name, ln)

#       Department.update(d.id, :long_name => ln)
#       #puts d.long_name
#       rescue StandardError => e
#         puts "rescued -" + e.message
#      end
#      puts "finished"
#     end
#   Department.find_each do |d|
#       puts d.long_name
#   end
# end


task :grades => :environment do
  puts "Grades start"
  Dir.glob('data/grades/grades.csv').each do |csv|
    puts "loading grades csv file: " + csv
    #puts Fcq.column_names
    CSV.foreach(csv, :headers => true) do |row|
      begin
          #puts row.to_hash
          #h = row.to_hash.select {|k,v| k == "instructor_first" || "k == instructor_last"}
          #inst = get_instructor(params)
          #inst.fcqs.create!(row.to_hash)
      r = row.to_hash
      # puts r.to_s
      #  puts "\n"
      #gets the fcq with the same courtitle, section, yearterm
      f_params = {"yearterm" => r["yearterm"], "subject" => r["subject"], "crse" => r["crse"], "sec" => r["sec"]}
      d_params = {"name" => r["subject"], "long_name" => r["subject_label"]}
      d_short = {"name" => r["subject"]}
      # puts f_params
      #puts "\n"
      #f = Fcq.create!(row.to_hash)
      #puts f.fcq_object
      # puts r
      # puts "==="
      Fcq.where(f_params).each do |f|
        # puts f.yearterm
        # puts f.instructor.name
        # puts Fcq.column_names
        f.update_attributes(r.slice(*Fcq.column_names))
        # f.update_attributes(r)
        # puts "saved fcq"
        f.save
      end
      rescue ActiveRecord::RecordInvalid => invalid
          puts invalid.message
          next
      rescue ActiveRecord::RecordNotUnique => unique
        next
      rescue ActiveRecord::UnknownAttributeError => unknown
        puts unknown.message
        next
      end
    end
  end
  puts 'Grades finish'
end

task :departments => :environment do
  puts "Departments start"
  Dir.glob('data/departments/departments.csv').each do |csv|
    puts "loading csv file: " + csv
    #puts Fcq.column_names
    CSV.foreach(csv, :headers => true) do |row|
      begin
          #puts row.to_hash
          #h = row.to_hash.select {|k,v| k == "instructor_first" || "k == instructor_last"}
          #inst = get_instructor(params)
          #inst.fcqs.create!(row.to_hash)
      r = row.to_hash
      r["campus"] = "BD"
      # puts r.to_s
      #  puts "\n"
      #gets the fcq with the same courtitle, section, yearterm
      # f_params = {"yearterm" => r["yearterm"], "subject" => r["subject"], "crse" => r["crse"], "sec" => r["sec"]}
      d_params = {"name" => r["name"]}
      #   puts "==="
      d = Department.where(d_params).first || Department.create!(r)
      d.update_attributes(r)
      d.save
      # puts r
      rescue ActiveRecord::RecordInvalid => invalid
        puts invalid.message
        next
      rescue ActiveRecord::RecordNotUnique => unique
        puts unique.message
        next
      rescue ActiveRecord::UnknownAttributeError => unknown
        puts unknown.message
        next
      end
    end
  end
  puts 'finish deparments'
end


task :course_titles => :environment do
  puts "course titles start"
  Dir.glob('data/courses/courses.csv').each do |csv|
    puts "loading csv file: " + csv
    #puts Fcq.column_names
    termlookup = {1 => "Spring",4 => "Summer",7=>"Fall"}.invert
    CSV.foreach(csv, :headers => true) do |row|
      begin
        r = row.to_hash
        c_params = { 'subject' => r['subject'], 'crse' => r['crsnum'] }
        c = Course.where(c_params).first
        unless c.nil?
          c.update_attribute(:course_title, r['crstitle'])
          c.save
        end

        # gets the first word
        term = termlookup[r['term'].split(' ')[0]]
        year = r['fyc'].to_i
        yearterm = (year * 10 + term).to_s
        # gets the last 3 characters of the course string, identifying the section
        sec = r['course'][-3..-1]
        f_params = { 'yearterm' => yearterm, 'subject' => r['subject'], 'crse' => r['crsnum'], 'sec' => sec}
        Fcq.where(f_params).each do |f|
          f.update_attribute(:course_title, r['crstitle'])
          f.update_attribute(:hours, r['avghrs'])
          f.update_attribute(:activity_type, r['actvtyp'])
          f.save
          puts "#{r['term']} #{r['course']}"
        end
      rescue ActiveRecord::RecordInvalid => invalid
        puts invalid.message
        next
      rescue ActiveRecord::RecordNotUnique => unique
        puts unique.message
        next
      rescue ActiveRecord::UnknownAttributeError => unknown
        puts unknown.message
        next
      end
    end
  end
  puts 'course titles finish'
end
