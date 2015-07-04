#! /bin/bash

#Run this on courses.xlsx to turn it into a proper csv. This creates multiple csvs, so we remove some of them.


#First, conver to multiple csvs 
ssconvert -S courses/courseinfo.xlsx courses/courses.csv

# #Import csvs: .2 is the total grades, .4 is the grades for the upper and lower division classes, .7 is the different dep. codes
rm *.csv.{0,2,3,4}

# #this is the file with the first 9 lines cut out 
# tail -n +9 grades.csv.2 > big_grades.csv

###############################################
#notes about columns in  grades.csv (start at 0)i:
 
# 0 Yearterm begins at 20067 and ends at 20141
# 1 CrsPBADept is the department 
# 2 CrsPBAColl is the college, ex: (Engineering = EN), (Arts and Science = AS), BU = Business
# 3 CrsPBADiv is the division-> POSSIBLY GARBAGE!
# 9 Acitivty type -> POSSIBLE GARBAGE!
# 11 Instruction Mode -> Only recent results 
# 39 Rank in Univerisity -> Possibly garbage? 
##############################################


 
