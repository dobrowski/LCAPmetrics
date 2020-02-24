# Instructions for updating in future years. 
# Update the "Dashboard_all.rds" file from Dashboard Rproject
# Update the year here
yr <- 2019

#




### Load libraries -----

library(tidyverse)
library(here)
library(vroom)

library(googledrive)

### Import data -------


metrics <- tibble("priority_area" = c(rep("Conditions for Learning",5),rep("Pupil Outcomes",7), rep("Engagement",10) ) ,
                  "priorities" = c(rep("Basic",3),"Standards","Access", rep("Pupil Achievement", 6), "Other Pupil Outcomes", rep("Parent Involvement",2), rep("Pupil Engagement", 5), rep("School Climate",3) ),
                  "metrics" = c("TeachersCred","Materials","GoodRepair","Standards","BroadCourse","CAASP","A_G","ELPI","reclass","AP","EAP","outcomes_other", "ParentInput","UnduplicatedParentPart","Attendance","ChronicAbs","MSdropout","HSdropout","HSgrad","susp","exp","local_other"),
                  "source" = c(rep("dash_local",5),rep("dash",3),"dq", "dash", "dq", "local",rep("dash_local",2), "local", "dash", rep("dq",2), rep("dash",2), "dq", "dash_local"   ),
                  "description" = c("Teachers: Fully Credentialed & Appropriately Assigned", 
                                      "Standards-aligned Instructional Materials for every student",
                                      "School Facilities in “Good Repair” per CDE’s Facility Inspection Tool (FIT)",
                                      "Implementation of all CA state standards including how ELs will access the CCSS and ELD standards", 
                                      "Students have access and are enrolled in a broad course of study (Social Science, Health, VAPA, Science, PE, World Language)",
                                      "State CAASPP assessments (ELA, CAA, Math, Science-CST/CMA/CAPA)", 
                                      "% of pupils that have successfully completed A-G requirements or CTE pathways (Add”l Dashboard Reports)", 
                                      "% of ELs who progress in English proficiency (ELPAC)",
                                      "EL reclassification rate",
                                      "% of pupils that pass AP exams with a score of 3 or higher (Add’l Dashboard Reports)",
                                      "Pupils prepared for college by the EAP (ELA/Math CAASPP Score of 3 or higher)",
                                      "If available, outcomes for subjects listd in course access" ,
                                      "Parent input in decision-making",
                                      "Parental Participation in programs for Unduplicated Pupils (UPs)", 
                                      "Attendance rates", 
                                      "Chronic absenteeism (CA) rates", 
                                      "Middle school dropout rates", 
                                      "High school dropout rates", 
                                      "High school graduation rates", 
                                      "Suspension rates", 
                                      "Expulsion rates", 
                                      "Other local measures (Surveys re safety and school connectedness)"
                                      )

)


dashboard_all <- read_rds(here("data","Dashboard_all.rds")) # Also at https://drive.google.com/open?id=1XqGRRjQaFMMVshgF0HhnL7Ch9lnxVEYD

dashboard_mry <- dashboard_all %>% 
    filter(str_detect("Monterey",countyname),
           year == yr)
    



### Manipulate -----

elpi <- dashboard_mry %>%
    filter(ind == "elpi") %>%
    select(cds:countyname, elpi = currstatus)

A_G <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    mutate(ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
           ag_cte_perc = ag_cte/currdenom) %>%
    select(cds:countyname,ag_cte_perc) 
# Note, this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. 
# It is not possible to get the exact figure with the aggregate data available


AP <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    mutate(ap = curr_prep_apexam/currdenom) %>%
    select(cds:countyname,ap ) 
# Note this is percentage of cohort that passed TWO AP exams. PErcentage that passed a single one is not available on Dashboard

chronic <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    select(cds:countyname, chronic = currstatus) 

grad <- dashboard_mry %>%
    filter(ind == "grad",
           studentgroup == "ALL") %>%
    select(cds:countyname, grad = currstatus) 

susp <- dashboard_mry %>%
    filter(ind == "susp",
           studentgroup == "ALL") %>%
    select(cds:countyname, susp = currstatus) 

math <- dashboard_mry %>%
    filter(ind == "math",
           studentgroup == "ALL") %>%
    select(cds:countyname, math = currstatus) 

ela <- dashboard_mry %>%
    filter(ind == "ela",
           studentgroup == "ALL") %>%
    select(cds:countyname, ela = currstatus) 

#  Should we add the Science CAASPP scores too?  


## EAP 
# % at level 3 on Math  ;  % at level 3 on ELA 


## Middle Drop out


## High School Drop out 

grad_vroom <- vroom("data/cohort5year1819.txt", .name_repair = ~ janitor::make_clean_names(., case = "upper_camel")) 

## Expelled 

exp_vroom <- vroom("data/exp1718.txt",.name_repair = ~ janitor::make_clean_names(., case = "upper_camel")) %>%
    mutate_at(vars(CumulativeEnrollment:ExpulsionCountDefianceOnly), funs(as.numeric) ) %>%
    mutate(rate = UnduplicatedCountOfStudentsExpelledTotal/CumulativeEnrollment)

## Credential Teachers

# % of teachers fully credentialed AND % of teachers appropriately assigned within their credential area (2 figures)
# 
# % of teachers who are BOTH fully credentialed and appropriately assigned. (if they are PIP, STIP, etc. they wouldn’t be in this count)


staff <- vroom("data/StaffSchoolFTE18.txt")

cred <- vroom("data/StaffCred18.txt")



staff.mry <- staff %>%
    filter(str_detect(CountyName,"Monterey"),
           JobClassification == "12") %>%  # Only teachers and not 10 = Administrator c("11 = Pupil services", "12 = Teacher", "25 = Non-certificated Administrator", "26 = Charter School Non-certificated Teacher", "27 = Itinerant or Pull-Out/Push-In Teacher")
    select(-FileCreated) %>%
    left_join(cred) %>%
    mutate(full_cred = if_else(CredentialType == "10", TRUE, FALSE))


cred_rate <- staff.mry %>%
    group_by(DistrictCode, SchoolCode, DistrictName, SchoolName) %>%
    mutate(cred.rate = mean(full_cred)) 

## Reclass ----

grad_vroom <- vroom("data/filesreclass19.txt", .name_repair = ~ janitor::make_clean_names(., case = "upper_camel"))


group_by(year) %>%
    transmute(`Reclassified Students` = sum(Reclass),
              `EL Enrollment` = sum(EL))


### Combine all the dashboard files ----

indicators <- list(A_G, AP, chronic, elpi, grad, susp, math, ela) %>%
    reduce( left_join)



### End -----
