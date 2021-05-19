# Instructions for updating in future years. 
# Update the "Dashboard_all.rds" file from Dashboard Rproject


### Load libraries -----

library(tidyverse)
library(here)
library(vroom)
library(readxl)
library(glue)
# library(MCOE) # Toggle this on an off.  It doesn't work on shiny with this enabled

yr <- 2020

options(scipen = 999)


con <- mcoe_sql_con()


### Import data -------

metrics <- tibble("priority_area" = c(rep("Conditions for Learning",8),rep("Pupil Outcomes",10), rep("Engagement",11) ) ,
                  "priorities" = c(rep("1. Basic",3),rep("2. Implement State Standards",2),rep("7. Course Access",3), rep("4. Pupil Achievement*", 9), "8. Other Pupil Outcomes", rep("3. Parent Involvement",3), rep("5. Pupil Engagement*", 5), rep("6. School Climate*",3) ),
                  "metrics" = c("cred.rate.wt","Materials","GoodRepair","Standards", "StandardsEL" , #5
                                "BroadCourse", "CourseUndup", "CourseSWD" , #8
                                "math", "ela" ,"ag_cte_perc", "ag_perc" , "cte_perc" ,"elpi","reclass_rate", #13
                                "ap_perc","eap","outcomes_other", "ParentInput","UnduplicatedParentPart", "ParentSWD", #19
                                "Attendance","chronic","MSdropout","DropoutRate","grad", #23
                                "susp","exp","local_other"),
                  "source" = c(rep("Local Dashboard Data",1),
                               rep("Local Dashboard Data and  district Williams Report",2),
                               "LEA and site CCSS implementation plans and teacher participation in CCSS training.",
                               "LEA and site CCSS and ELD implementation plans and teacher participation in CCSS and ELD training.", #5
                               rep("student information systems", 3),
                               rep("Dashboard",2),#10
                               "",
                               rep("Dashboard",3), 
                               "Dataquest",#15 # https://www.cde.ca.gov/ci/gs/hs/eapindex.asp  doesn't exist, maybe in CCI? 
                               "Dashboard",
                               "CAASPP results",
                               "Local data",
                               "Local Dashboard Data and district and school surveys related to WASC and Single Plan Student Achievement, or DLAC/ELAC",
                               rep("Local Dashboard Data and local data on parent involvement in district/school activities (e.g., committees, student clubs, promotion activities, PTO membership, etc.)",2),#20
                               "student information systems",
                               "Dashboard",
                               rep("student information systems",2),
                               "Dashboard", #25
                               "Dataquest", 
                               "Dataquest", 
                               "Local Dashboard Data and from such sources as LEA plans, School Site Council activities, and English Learner Advisory Council materials"   ),
                  "description" = c("Teachers: Fully Credentialed & Appropriately Assigned", 
                                    "Standards-aligned Instructional Materials for every student",
                                    "School Facilities in “Good Repair” per CDE’s Facility Inspection Tool (FIT)",
                                    "Implementation of all CA state standards for all students", 
                                    "Implmentation of how ELs will access the CCSS and ELD standards", #5
                                    "Students have access and are enrolled in a broad course of study (Social Science, Health, VAPA, Science, PE, World Language)", 
                                    "Students have access and are enrolled in programs and services developed and provided to low income, English learner and foster youth pupils",
                                    "Students have access and are enrolled in programs and services developed and provided to students with disabilities.", #8
                                    
                                    "State CAASPP assessments (Math DFS)", 
                                    "State CAASPP assessments (ELA DFS)", 
                                    "Percent of pupils that have successfully completed both A-G courses and CTE courses", 
                                    "Percent of pupils that have successfully completed A-G courses", 
                                    "Percent of pupils that have successfully completed CTE courses", 
                                    "Percent of ELs who progress in English proficiency (ELPAC)",
                                    "EL reclassification rate", #13
                                    "Percent of pupils that pass AP exams with a score of 3 or higher",
                                    "Pupils prepared for college by the EAP (ELA/Math CAASPP Score of 3 or higher)",
                                    "If available, outcomes for subjects listed in course access" ,
                                    "Parent input in decision-making",
                                    "Parental Participation in programs for Unduplicated Pupils (UPs)", #18
                                    "Parental Participation in programs for Students with Disabilities", 
                                    "Attendance rates", 
                                    "Chronic absenteeism (CA) rates", 
                                    "Middle school dropout rates", 
                                    "High school dropout rates", 
                                    "High school graduation rates", #24
                                    "Suspension rates", 
                                    "Expulsion rates", 
                                    "Other local measures (Surveys regarding safety and school connectedness)"
                  ),
                  "website" = c("https://www.cde.ca.gov/ds/sd/df/filesstaffdemo.asp",
                                rep("",7), #5
                                rep("Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",2),
                                "",
                                rep("Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/",2),
                                "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",
                                "https://www.cde.ca.gov/ds/sd/sd/filesreclass.asp", #10
                                "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/",
                                "caaspp-elpac.cde.ca.gov",
                                rep("",5), #16
                                "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",
                                "",
                                "https://www.cde.ca.gov/ds/sd/sd/filesacgr.asp",
                                "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/", #20
                                "https://www.cde.ca.gov/ds/sd/sd/filessd.asp",
                                "https://www.cde.ca.gov/ds/sd/sd/filesed.asp",
                                rep("",1)
                  ),
                  "notes" = c( "Please note this only looks at teachers and not adminstrators, pupil services, itinerant nor push-in/pull-out teachers. The most recent available public data is 2018-19. It is grouped at the district level, and is weighted by percent FTE.  It does not yet look at proper assignment of teachers, only credential status. Please also reference your Williams Report."  ,
                               rep("",7), #5
                               rep("Since this is from 2018-19, it is recommended to use local data, such as interims or NWEA, rather than data from two years ago.",2),
                               "It is not possible to calculate students that completed both A-G courses and also completed a CTE course with public data. Your SIS or CALPADS Report 3.15 and 15.2 may be helpful.", # just use the CCI indicator too. 
                               rep("Note 2019-20 data is available on the Dashboard. This is calculated using the number of students prepared and approaching prepared. ",2), # just use the CCI indicator too. 
                               rep("",2), #10  #  Look at Title III AMOA 2  reporting
                               "Note 2019-20 data is available on the Dashboard. Please note this is the percentage of the graduating cohort that passed TWO AP exams. The percentage of students that passed a single AP exam is not available on the Dashboard. Please also look at College Board Online https://scores.collegeboard.org/pawra/home.action",  #  Look at AP data file,  also add link to College Board Online https://scores.collegeboard.org/pawra/home.action
                               rep("",2),  #   https://www.cde.ca.gov/ci/gs/hs/eapindex.asp
                               "",
                               "",
                               "",
                               "Consider daily participation or weekly engagement records.", #15

                               "CALPADS Report 14.1 and 14.2 may be helpful.", #17
                               "Please note LEAs can find middle school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)",
                               "Please note LEAs can find high school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades nine through twelve)",
                               "Note 2019-20 data is available on the Dashboard.  CALPADS Report 15.1 and 15.2 may be helpful.", #20
                               "CALPADS Report 7.10 and 7.12 may be helpful.",
                               "Please note this is a rate per thousand students.",
                               ""
                  )
) %>% 
    arrange(priorities)

write_rds(metrics, "metrics.rds")

# dashboard_all <- read_rds(here("data","Dashboard_all.rds")) # Also at https://drive.google.com/open?id=1XqGRRjQaFMMVshgF0HhnL7Ch9lnxVEYD
# 
# dashboard_mry <- dashboard_all %>% 
#     filter(str_detect("Monterey",countyname),
#            year == yr) %>%
#     mutate(cds = as.numeric(cds)) %>%
#     mutate(cds = as.character(cds))
# 
# write_rds(dashboard_mry, "dashboard_mry.rds")




csi_all <- read_excel(here("data","essaassistancestudentgroup19.xlsx"), range = "A3:G9975")

csi_mry <- csi_all %>%
    filter( str_extract(cds, "[1-9]{1,2}") == 27,
            str_detect(AssistanceStatus2019, "CSI")) %>%
    mutate(cds = paste0(str_extract(cds, "[0-9]{1,7}"),"0000000"  ))

write_rds(csi_mry, "csi_mry.rds")


### Manipulate -----


pull.dash <- function(tablename, col){
        tbl(con, tablename) %>%
        filter(studentgroup == "ALL",
               reportingyear == max(reportingyear)) %>%
        select(cds:countyname,  currstatus)  %>%
        collect()  %>%
        filter(str_detect(countyname,"Monterey")) %>%
        rename(!!col := currstatus)   # Note the :=  because of passing string to left side of argument
}



chronic <- pull.dash("DASH_CHRONIC","chronic")

grad <- pull.dash("DASH_GRAD","grad")

susp <- tbl(con, "SUSP") %>%
         filter(reporting_category == "TA",
                academic_year == max(academic_year),
                aggregate_level == "D",
                charter_yn == "No") %>%  # To only get districts and because elementary and high school have suspensions this is the initial key
         select(county_code:county_name, susp = suspension_rate_total) %>%
         collect()  %>%
    mutate(cds = paste0(county_code,district_code,school_code)) %>%
         filter(str_detect(county_name,"Monterey")) %>%
    select(cds, susp)

math <- pull.dash("DASH_MATH","math")

ela <- pull.dash("DASH_ELA","ela")

elpi <- tbl(con, "DASH_ELPI") %>%
    select(cds:countyname, elpi = currstatus) %>%
    collect()

A_G <- tbl(con, "DASH_CCI") %>%
    filter(studentgroup == "ALL",
           reportingyear == max(reportingyear)) %>%
    mutate(# ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
           # ag_cte_perc = ag_cte*100/currdenom ,
           ag_perc = (curr_prep_agplus + curr_aprep_ag) / currdenom ,
           cte_perc = (curr_prep_cteplus + curr_aprep_cte) / currdenom ,
           ap_perc = (curr_prep_apexam ) / currdenom ,
           )  %>%
    select(cds:countyname, ends_with("perc")) %>%
    collect() %>%
    filter(str_detect(countyname,"Monterey")) # %>%
#    mutate(ap = (curr_prep_apexam/currdenom) %>% round2(3)*100)

# Note, this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. 
# It is not possible to get the exact figure with the aggregate data available


# AP <- dashboard_mry %>%
#     filter(ind == "cci",
#            studentgroup == "ALL") %>%
#     mutate(ap = (curr_prep_apexam/currdenom) %>% round2(3)*100) %>%
#     select(cds:countyname,ap ) 
# Note this is percentage of cohort that passed TWO AP exams. PErcentage that passed a single one is not available on Dashboard


#  Should we add the Science CAASPP scores too?  


## EAP 
# % at level 3 on Math  ;  % at level 3 on ELA 

eap.full <- tbl(con, "CAASPP") %>%
    filter(Subgroup_ID == "1",
           Test_Year == max(Test_Year),
           County_Code == "27",
           School_Code == "0000000",
           Grade == "11") %>%  
    select(County_Code:Test_Id, eap = Percentage_Standard_Met_and_Above) %>%
    collect()  


eap <- eap.full %>%
    mutate(cds = paste0(County_Code,District_Code,School_Code),
           eap = as.numeric(eap)
           ) %>%
    select(cds, Test_Id ,eap) %>%
    pivot_wider(names_from = Test_Id, values_from = eap ) %>%
    na.omit() %>%
    mutate(eap = glue("{round(`1`,1)}% in ELA and {round(`2`,1)}% in Math") ) %>%
    select(cds,eap)




## Middle Drop out

# Local educational agencies looking for information about middle school dropouts can obtain information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)

## High School Drop out 


drop <- tbl(con, "GRAD_FOUR")  %>% 
#    mutate_at(vars(CohortStudents:DropoutRate), funs(as.numeric) ) %>%
    filter( ReportingCategory == "TA",
            CharterSchool =="No",
            Dass == "All",
            CountyName == "Monterey",
            AcademicYear == max(AcademicYear)) %>%
    collect() %>%
    mutate(cds = paste0(CountyCode,DistrictCode,SchoolCode)) %>%
     select(cds, Dropout_Rate) 



## Expelled 


exp <- tbl(con, "EXP")  %>%
#    mutate_at(vars(CumulativeEnrollment:ExpulsionCountDefianceOnly), funs(as.numeric) ) %>%
    filter(county_name == "Monterey",
           reporting_category == "TA",
           academic_year == max(academic_year),
           charter_yn == "All"
           ) %>%  # Charter included Yes/No
    collect() %>%
    mutate(exp = (unduplicated_count_of_students_expelled_total*1000/cumulative_enrollment)%>% round2(3) )  %>%
    mutate(cds = paste0(county_code,district_code,school_code))  %>%
    select(cds, exp)

## Credential Teachers

# % of teachers fully credentialed AND % of teachers appropriately assigned within their credential area (2 figures)
# 
# % of teachers who are BOTH fully credentialed and appropriately assigned. (if they are PIP, STIP, etc. they wouldn’t be in this count)


cred <-  tbl(con, "STAFF_CRED") %>%
    filter(AcademicYear == max(AcademicYear)) %>%
    select(RecID, CredentialType) %>%
    distinct()

staff.mry <- tbl(con, "STAFF_SCHOOL_FTE") %>%
    filter(CountyName =="Monterey",
           JobClassification == "12",
           AcademicYear == max(AcademicYear)) %>%  # Only teachers and not 10 = Administrator c("11 = Pupil services", "12 = Teacher", "25 = Non-certificated Administrator", "26 = Charter School Non-certificated Teacher", "27 = Itinerant or Pull-Out/Push-In Teacher")
    select(-FileCreated, -YEAR, -AcademicYear) %>%
    left_join(cred)  %>%
 #   mutate(full_cred = if_else(CredentialType == "10", TRUE, FALSE)) %>% 
    collect() %>%
    mutate(full_cred = if_else(CredentialType == "10", TRUE, FALSE)) 




cred_rate <- staff.mry %>%
    group_by(DistrictCode, DistrictName) %>%
    transmute(cred.rate.wt = weighted.mean(full_cred, FTE , na.rm = TRUE ),
              cds = paste0(DistrictCode,"0000000")) %>%
    ungroup() %>%
    distinct() %>%
    mutate(cred.rate.wt = cred.rate.wt %>% round2(3)*100)

## Reclass ----

reclass <- tbl(con, "RECLASS") %>%
    filter(County =="Monterey",
 #          YEAR == max(YEAR)
           ) %>%
    collect()    %>%
group_by(District, YEAR) %>%
    mutate(reclassified = sum(Reclass),
           ELenroll = sum(EL)) %>%
    ungroup() %>%
    mutate(  cds = paste0(str_sub(CDS,1,7),"0000000") ) %>%
    select(YEAR, District, cds, reclassified, ELenroll) %>%
    distinct() %>%
    mutate(YEAR = case_when(YEAR == max(YEAR) ~ "new",
                            YEAR ==  max( YEAR[YEAR!=max(YEAR)] ) ~ "new_minus_one",  # Reclass rate is calculated by RFEPs in a given year divided by total EL in previous year
                            TRUE ~ "old"))  %>%
    filter(YEAR != "old"  ) %>%
    pivot_wider(values_from = c("reclassified", "ELenroll"), names_from = "YEAR") %>%
    transmute(cds,
        reclass_rate = (reclassified_new*100/ELenroll_new_minus_one) %>% round2(1) ) 

### Combine all the dashboard files ----

indicators <- list(   susp,exp , math, ela, 
                      A_G, eap, # AP,
                      chronic, elpi, grad, drop, reclass,
                      cred_rate) %>%
    reduce( left_join)


indicators <- indicators %>%
    mutate(susp = scales::percent( susp/100 , accuracy = .1 ),
           cred.rate.wt = scales::percent( cred.rate.wt/100 , accuracy = .1 ),
           elpi = scales::percent( elpi/100 , accuracy = .1 ),
           reclass_rate = scales::percent( reclass_rate/100 , accuracy = .1 ),
           ap_perc = scales::percent( ap_perc , accuracy = .1 ),
           ag_perc = scales::percent( ag_perc , accuracy = .1 ),
           cte_perc = scales::percent( cte_perc , accuracy = .1 ),
           chronic = scales::percent( chronic/100 , accuracy = .1 ),
           grad = scales::percent( grad/100 , accuracy = .1 ),
           Dropout_Rate = scales::percent( Dropout_Rate/100 , accuracy = .1 ),
  #         ag_cte_perc = scales::percent( ag_cte_perc/100 , accuracy = .1 )
           
           
           )


write_rds(indicators ,here("indicators.rds"))


### Unduplicated Count -------

undup.count <- tbl(con, "UPC") %>%
    filter(academic_year == max(academic_year),
           county_code == "27",
           #school_code == "0000000"
           ) %>%
    collect()  %>%
    group_by(county_code,district_code) %>%
    transmute(undup.perc = sum(calpads_unduplicated_pupil_count_upc)/sum(total_enrollment),
              cds = glue('{county_code}{district_code}0000000') ) %>%
    distinct()


write_rds(undup.count ,here("undup.rds"))

### End -----
