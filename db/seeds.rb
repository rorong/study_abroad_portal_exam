# Define all constants at the top
BOARD_NAMES = [
  "CBSE", "ICSE", "IB", "GCE", "NIOS", "TELANGANA BOARD", "Gujarat BOARD",
  "Karnataka BOARD", "Tamil Nadu Board", "Punjab State Board", "Haryana Board",
  "Maharashtra Board", "Andhra Pradesh Board", "West Bengal Board",
  "other State Board", "Chhattisgarh Board", "Madhya Pradesh Board",
  "Jammu and Kashmir Board", "Kerala Board", "Rajasthan Board"
]

TEST_NAMES = ["GMAT", "GRE", "SAT", "IELTS", "TOEFL", "PTE"]
EXAM_TYPES = [:overall, :reading, :writing, :speaking, :listening]

# Create Education Boards and related data
BOARD_NAMES.each do |board_name|
  board = EducationBoard.find_or_create_by!(board_name: board_name)
  
  ["Class 10", "Class 12"].each do |level_name|
    academic_level = AcademicLevel.find_or_create_by!(
      level_name: level_name,
      education_board: board
    )
    
    ["English", "Physics", "Chemistry", "Mathematics", "Biology"].each do |subject_name|
      Subject.find_or_create_by!(
        name: subject_name,
        academic_level: academic_level,
        education_board: board
      )
    end
  end
end
departments = [
  'Engineering',
  'Marketing',
  'Human Resources',
  'Law',
  'Economics',
  'Computer Science',
  'Business Administration'
]

departments.each do |dept_name|
  Department.find_or_create_by!(name: dept_name) do |dept|
    puts "Created department: #{dept.name}"
  end
rescue ActiveRecord::RecordInvalid => e
  puts "Error creating department: #{dept_name} - #{e.message}"
end

# Create standardized tests
TEST_NAMES.each do |test_name|
  EXAM_TYPES.each do |exam_type|
    StandardizedTest.create!(
      test_name: test_name,
      exam_type: exam_type
    )
  end
end

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# 