#check if the patient id is an integer of 7 digits
validate_patient_id() {
    local patientId=$1
    touch dummy.txt
    if ! echo "$patientId"  | grep '[0-9]\{7\}' > dummy.txt
      then       
        echo "Invalid ID"
        return 1
    fi
    return 0
}

#check if the test exist
check_test_existence() {
    local patientTest=$1
    touch dummy.txt
    touch tests.txt
 
    sed 's/.*(//' medicalTest.txt | sed 's/).*//' > tests.txt
 
    if ! grep -i "$patientTest" tests.txt > dummy.txt
       then
        echo "The test does not exist"
        return 1
   fi
   return 0
}

#check if the date is in the form yyyy-mm and the month is between 1 and 12
validate_date() {
    local Date=$1
    touch dummy.txt
    if ! echo "$Date" | grep -E '^[0-9]{4}-(0[1-9]|1[0-2])$' > dummy.txt
     then
      echo "the Date is invalid"
      return 1
   fi   
   return 0
}

#check if the status is pending , completed , or reviewed
validate_status() {
    local status=$1
    touch dummy.txt
    if ! echo "$status" | grep -iE '^(pending|completed|reviewed)$' > dummy.txt
     then
      echo "Invalid status"
      return 1
   fi
     return 0
}

#check if the result is an integer or float
validate_result() {
     local result=$1
     touch dummy.txt
     if ! (echo "$result" | grep '[0-9]\.[0-9]' || echo "$result" | grep '[0-9]') > dummy.txt
       then
       echo "Invalid result"
       return 1
   fi
   return 0
}



Add_new_test() {
echo "enter patient Id"
read patientId
while ! (validate_patient_id "$patientId")
    do
     echo "please enter a valid id"
     read patientId
    done

echo "enter test name"
read testName
while ! (check_test_existence "$testName")
    do
     echo "please enter a valid test name"
     read testName 
    done


echo "enter the test Date"
read Date
while ! (validate_date "$Date")
    do
     echo "please enter a valid date"
     read Date
    done


echo "enter the test status"
read status
while ! (validate_status "$status")
    do
     echo "please enter a valid status"
     read status
    done

echo "enter the test result"
read result
while ! (validate_result "$result")
    do
     echo "please enter a valid result"
     read result
    done
tempTestName=$(echo "$testName" | tr '[A-Z]' '[a-z]')

#append the unit to the result
case "$tempTestName" in
    hgb)
        result="$result, g/dL"
        ;;
    bgt)
        result="$result, mg/dL"
        ;;
    ldl)
        result="$result, mg/dL"
        ;;
    systole)
        result="$result, mm Hg"
        ;;
    diastole)
        result="$result, mm Hg"
        ;;
    *)
        ;;
esac
echo "$patientId: $testName, $Date, $result, $status" >> medicalRecord.txt
}




search_for_upNormal_tests() {
    echo "Enter a medical test:"
    read medicalTest

    while ! (check_test_existence "$medicalTest"); do
        echo "Please enter a valid test name:"
        read medicalTest
    done
   
     # Extract the range values from  medicalTest.txt file
    lowValue=$(grep -i "$medicalTest" medicalTest.txt | grep '>' | sed 's/.*> //' | sed 's/, <.*//')
    highValue=$(grep -i "$medicalTest" medicalTest.txt | sed 's/.*< //' | sed 's/; Unit.*//')
    echo "The up normal tests:"
     
    #create a file for the tests of the input medicalTest to make it easy to loop through them
    touch Test
    grep -i "$medicalTest" medicalRecord.txt > Test

    while read test; do
        
        if [ -n "$test" ]; then
           #extract the result from the patient test 
           result=$(echo "$test" | cut -d: -f2 | cut -d',' -f3 | sed 's/ //g')

            # Check if result is higher than highValue
            if [ "$(echo "$result > $highValue" | bc)" -eq 1 ]; then
                echo "$test"
            # Check if result is lower than lowValue 
            elif [ -n "$lowValue" ] && [ "$(echo "$result < $lowValue" | bc)" -eq 1 ]; then
                echo "$test"
            fi
        fi  
    done < Test
}
calc_avg() {

touch tests.txt
touch dummy.txt

#extract all the testnames and add them to a seperate file
sed 's/.*(//' medicalTest.txt | sed 's/).*//' > tests.txt

touch Test
#loop through tests
while read tests
 do
  if [ -n "$tests" ]
   then
#extract the petints tests of a specific test
# and add them to Test file to easily loop through them and calulate the avg
     grep -i "$tests" medicalRecord.txt  > Test
     resultAvg=0 
     count=0
     while read Test
      do
       result=$(echo "$Test" | cut -d: -f2 | cut -d',' -f3 | sed 's/ //g')
       resultAvg=$(echo "$resultAvg + $result" | bc)
       count=$((count+1))

      done < Test

     resultAvg=$(echo "scale=2; $resultAvg / $count" | bc)
     echo "average result of $tests is : $resultAvg"

    fi

   done < tests.txt

}



update_test() {
touch dummy.txt
echo "enter the patient Id"
read patientId

#ensure that the patientId is integer of 7 digits and that patientId exist
valid=0
while [ "$valid" -eq 0 ]
do
  if ! (validate_patient_id "$patientId")
     then  
      echo "please enter a valid id"
      read patientId
      continue
    fi
  if ! (grep -i "$patientId" medicalRecord.txt) > dummy.txt
     then
      echo "This patient ID does not exist"
      echo "please enter another id"
      read patientId
      continue
     fi
  valid=1
done

echo "enter test name"
read testName

#ensure that the test exist and if it exists ensure that patient has this test
valid=0
while [ "$valid" -eq 0 ]
do
  if ! (check_test_existence "$testName")
     then
      echo "please enter a valid test name"
      read testName
      continue  
    fi
   if ! (grep -i "$testName" medicalRecord.txt | grep "$patientId") > dummy.txt
       then
         echo "this patient did not have this test"
          read testName
          continue    
     fi
  valid=1
done

#ensure that the new result is valid (integer)
echo "Enter the new result"
read newResult
while ! (validate_result "$newResult")
    do
     echo "please enter a valid result"
     read newResult
    done
#replace the old result with the new one
sed  -i '' "/$patientId.*$testName/s/, [0-9]*,/, $newResult,/" medicalRecord.txt

}







##################################################################
printf "please enter the name of the file , if you want exit enter -1\n"
read medicalRecord   #read the file that contains all medical test
while [ ! -e $medicalRecord ]   #check the file exist or not
do
	printf "the file does not exist please enter the file name again or -1 to exit from the program\n"
	read medicalRecord
if [ "$medicalRecord" = "-1" ]
then
	printf "-Good Bye-\n"
	sleep 2
	exit -1
fi
done
#loop for the user to chose from it 
while true
do
printf "\n\n\t****Welcome to Medical Test Management System***\n\n
	\t\t\tMAIN MENU\n
	=====================================================\n
	[1]Add a new medical test record
	[2]Search for a test by patient ID
	[3]Search for up normal tests
	[4]Retrieve average test value
	[5]Update test result
	[6]Delete test result
	[0]exit from the progrm\n
	====================================================\n
	Enter the choice : \n"
read choice
#if the choice equal to zero then exit from the program
if [ $choice -eq 0 ]
then
printf "Thanks for select my program Medical Test Management System\n"
sed -i '/[a-zA-Z]/d' medical.txt
exit 0
#check if the choice is valid
elif [ $choice -lt 1 -o $choice -gt 6 ]
then
	printf " You Should enter the number from 0-6 \n"
	continue
elif [ $choice -eq 1 ]
then
	Add_new_test
#if choice is 2 then will  be shown the menu  for user to select what option will be do foe specific id enter
elif [ $choice -eq 2 ]
then
	#ask the user to enter id patient
	printf "Please enter the patient ID :  \n"
	while true; do
	read  patientId
	      if grep -q "$patientId" $medicalRecord 
		then
			break
	else
	     printf " \n This patient ID doesnot exit please enter another ID \n"
	fi
	done
        while ! (validate_patient_id "$patientId")
        do
         	echo "please enter a valid id"
         	read patientId

        done

	#read ID  #read the id from user
	#printf "\n\n\t---Welcome to the user that patient ID is  "$ID" \n"
	#loop for the user to chose from it 
	while true
	do
	  printf "\n\n\t\\t\tMedical Management System\n\n
                 \t\tMAIN MENU\n
            =====================================================\n
		[1] Retrieve all patient tests
		[2] Retrieve up normal tests
		[3] Retrieve patient tests on specific period
		[4] Retrieve patient tests based on test status
		[0] exit from menu\n
	    =====================================================\n
		Enter the option : \n"
		read op   #read option
		#if option is 0 then  will be exit from menu
		if [ $op -eq 0 ]
		then
			printf "Good Bye\n"
			break
		#if the option is 1  then  will be retrieve all patient tests for the id has been enter at first
		elif [ $op -eq 1 ]
		then

		       printf "\n All patient test for this "$patientId" is : \n"
                       grep .*"$patientId".* $medicalRecord ||printf "it is not exist \n"
			#store all lines that retreive in the file called dates.txt because will be use this file in another part in this project
		       grep .*"$patientId".* $medicalRecord >> medical.txt ||printf "it is not exist \n"
                      # sort -n dates.txt >> data.txt
                       printf "\n"
			#if the option is 2 then will be retrieve all upnormal patient tests
                elif [ $op -eq 2 ]
		    then
                    touch Test

		     printf "\n  Up normal  test  is  : \n"
		    
                   grep -i "$patientId: " medicalRecord.txt > Test 
                   while read test; do
                 
                   if [ -n "$test" ]; then
                   medicalTest=$(echo "$test" | cut -d: -f2 | cut -d',' -f1 | sed 's/ //g')

                   #extract the result from the patient test
                   result=$(echo "$test" | cut -d: -f2 | cut -d',' -f3 | sed 's/ //g')
                   # Extract the range values from  medicalTest.txt file
                
                   lowValue=$(grep -i "$medicalTest" medicalTest.txt | grep '>' | sed 's/.*> //' | sed 's/, <.*//')
                   highValue=$(grep -i "$medicalTest" medicalTest.txt | sed 's/.*< //' | sed 's/; Unit.*//')
                  
                    # Check if result is higher than highValue
                    if [ "$(echo "$result > $highValue" | bc)" -eq 1 ]; then
                        echo "$test"
                       # Check if result is lower than lowValue
                    elif [ -n "$lowValue" ] && [ "$(echo "$result < $lowValue" | bc)" -eq 1 ]; then
                       echo "$test"
            fi
          fi
        done < Test
     
			    

		#if the option is 3 then will be retrieve all patient tests between specific period
		elif [ $op -eq 3 ]
		then
               while true; do
               # Prompt for the initial period (YYYY-MM)
               printf "\nPlease enter the initial period like YYYY-MM: \n"
               read l1
               while ! (validate_date "$l1"); do
               echo "Please enter a valid date"
               read l1
              done
               y1=$(echo "$l1" | cut -d- -f1)
               m1=$(echo "$l1" | cut -d- -f2)
               m1=$(echo "$m1" | sed 's/^0*//')

              # Prompt for the final period (YYYY-MM)
              printf "\nPlease enter the final period like YYYY-MM: \n"
              read l2
             while ! (validate_date "$l2"); do
               echo "Please enter a valid date"
                read l2
              done
              y2=$(echo "$l2" | cut -d- -f1)
              m2=$(echo "$l2" | cut -d- -f2)
              m2=$(echo "$m2" | sed 's/^0*//')

              # Check if the initial year is greater than the final year
              if [ "$y1" -gt "$y2" ]; then
            echo "Please enter a smaller initial year than the final year."
             elif [ "$y1" -eq "$y2" ] && [ "$m1" -gt "$m2" ]; then
            echo "In the same year, the initial month must be smaller than the final month."
            else
            # If valid, break the loop
            break
        fi
    done
               touch Test
                 grep -i "$patientId: " medicalRecord.txt > Test

                while IFs= read -r line; do
                date=$(echo "$line" | cut -d: -f2 | cut -d',' -f2 | sed 's/ //g')
                year=$(echo "$date" | cut -d- -f1)
                month=$(echo "$date" | cut -d- -f2)
                month=$(echo "$month" | sed 's/^0*//')

                if [[ ( "$year" -gt "$y1" || ( "$year" -eq "$y1" && "$month" -ge "$m1" ) ) &&
                         ( "$year" -lt "$y2" || ( "$year" -eq "$y2" && "$month" -le "$m2" ) ) ]]; then

                         echo "$line"
                fi

               done < Test
	      # if the option is 4 then will be retrieve test based on test status
	      elif [ $op -eq 4 ]
	      then
                   printf "\nPlease enter the status  : \n"
	          read status
                   while ! (validate_status "$status")
                     do
    			 echo "please enter a valid status"
    			 read status
    			 done

		  # s=""
	          # read s
		   printf " The Result is : \n"
		 #  grep -i .*"$status".* "$medical" ||printf "it is not exist \n"
		grep "$patientId" "$medicalRecord" | grep -i "$status" || printf "It does not exist\n"
	      fi
	 done

elif [ $choice -eq 3 ]
	then 
               search_for_upNormal_tests
		
elif [ $choice -eq 4 ]
	then
		calc_avg
elif [ $choice -eq 5 ]
	then
		update_test
# if option is 6 then will be delete the test from file 
elif [ $choice -eq 6 ]
	then
	echo "Enter the ID to delete:" #ask the user to enter the patient id to delete  a test
	read patientId  
       #ensure that the patientId is integer of 7 digits and that patientId exist 
       valid=0
       touch tests 
     while [ "$valid" -eq 0 ]
     do
     if ! (validate_patient_id "$patientId")  
     then
      echo "please enter a valid id"
      read patientId
      continue
    fi
     if ! (grep -i "$patientId" medicalRecord.txt) > tests
     then
      echo "This patient ID does not exist"
      echo "please enter another id"
      read patientId
      continue
     fi
   valid=1
     done
    grep -n "$patientId" tests
 echo "Enter the line number to delete from 'medicalRecord.txt':"
    read lineNumber
 # Extract the content of the specified line from 'tests'
    lineContent=$(sed -n "${lineNumber}p" tests)
    
    # Check if lineContent is empty
    if [ -z "$lineContent" ]
    then
        echo "Invalid line number or no matching content found. Aborting."
        exit 1
    fi
    
    # Escape special characters in the line content for sed
    escapedLineContent=$(echo "$lineContent" | sed 's/[\/&]/\\&/g')
    
    # Delete the line from 'medicalRecord.txt' that matches the escaped content
    sed -i '' "/${escapedLineContent}/d" medicalRecord.txt
    
    # Confirm the operation
    echo "The test with ID $patientId has been deleted from medicalRecord.txt."
    cat medicalRecord.txt    
fi
done	
