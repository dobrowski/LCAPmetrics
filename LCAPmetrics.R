# Instructions for updating in future years. 
# Update the "Dashboard_all.rds" file from Dashboard Rproject


### Load libraries -----

library(tidyverse)
library(here)
library(vroom)
library(readxl)

yr <- 2019

options(scipen = 999)

`%notin%` <- Negate(`%in%`)

round2 = function(x, digits) {
    posneg = sign(x)
    z = abs(x)*10^digits
    z = z + 0.5
    z = trunc(z)
    z = z/10^digits
    z*posneg
}


### Import data -------

metrics <- tibble("priority_area" = c(rep("Conditions for Learning",5),rep("Pupil Outcomes",8), rep("Engagement",10) ) ,
                  "priorities" = c(rep("1. Basic",3),"2. Implement State Standards","7. Course Access", rep("4. Pupil Achievement", 7), "8. Other Pupil Outcomes", rep("3. Parent Involvement",2), rep("5. Pupil Engagement", 5), rep("6. School Climate",3) ),
                  "metrics" = c("cred.rate.wt","Materials","GoodRepair","Standards","BroadCourse","math", "ela" ,"ag_cte_perc","elpi","reclass_rate","ap","EAP","outcomes_other", "ParentInput","UnduplicatedParentPart","Attendance","chronic","MSdropout","DropoutRate","grad","susp","exp","local_other"),
                  "source" = c(rep("Local Dashboard Data",5),rep("Dashboard",4),"Dataquest", "Dashboard", "Dataquest", "Local data",rep("Local Dashboard Data",2), "Local data", "Dashboard", rep("Dataquest",2), rep("Dashboard",2), "Dataquest", "Local Dashboard Data"   ),
                  "description" = c("Teachers: Fully Credentialed & Appropriately Assigned", 
                                      "Standards-aligned Instructional Materials for every student",
                                      "School Facilities in “Good Repair” per CDE’s Facility Inspection Tool (FIT)",
                                      "Implementation of all CA state standards including how ELs will access the CCSS and ELD standards", 
                                      "Students have access and are enrolled in a broad course of study (Social Science, Health, VAPA, Science, PE, World Language)",
                                      "State CAASPP assessments (Math DFS)", 
                                    "State CAASPP assessments (ELA DFS)", 
                                    "Percent of pupils that have successfully completed A-G requirements or CTE pathways", 
                                      "Percent of ELs who progress in English proficiency (ELPAC)",
                                      "EL reclassification rate",
                                      "Percent of pupils that pass AP exams with a score of 3 or higher",
                                      "Pupils prepared for college by the EAP (ELA/Math CAASPP Score of 3 or higher)",
                                      "If available, outcomes for subjects listed in course access" ,
                                      "Parent input in decision-making",
                                      "Parental Participation in programs for Unduplicated Pupils (UPs)", 
                                      "Attendance rates", 
                                      "Chronic absenteeism (CA) rates", 
                                      "Middle school dropout rates", 
                                      "High school dropout rates", 
                                      "High school graduation rates", 
                                      "Suspension rates", 
                                      "Expulsion rates", 
                                      "Other local measures (Surveys regarding safety and school connectedness)"
                                      ),
                  "website" = c("https://www.cde.ca.gov/ds/sd/df/filesstaffdemo.asp",
                                rep("",4),
                                rep("https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",4),
                                "https://www.cde.ca.gov/ds/sd/sd/filesreclass.asp",
                                "https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",
                                rep("",5),
                                "https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",
                                "",
                                "https://www.cde.ca.gov/ds/sd/sd/filesfycgr.asp",
                                rep("https://www.cde.ca.gov/ta/ac/cm/datafiles2019.asp",2),
                                "https://www.cde.ca.gov/ds/sd/sd/filesed.asp",
                                rep("",1)
                                ),
                  "notes" = c( "Please note this only looks at teachers and not adminstrators, pupil services, itinerant or push-in/pull-out teachers. The most recent available public data is 2017-18. It is grouped at the district level, and is weighted by percent FTE.  It does not yet look at proper assignment of teachers, only credential status" ,
                               rep("",6) ,
                               "Please note this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. It is not possible to get the exact figure with the aggregate data available",
                               rep("",2),
                               "Please note this is the percentage of the graduating cohort that passed TWO AP exams. The percentage of students that passed a single AP exam is not available on the Dashboard",
                               rep("",2),
                               "One possible example is a rating on a self-assessment tool.",
                               rep("",3),
                               "Please note LEAs can find middle school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)",
                               rep("",3),
                               "Please note this is a rate per thousand students.",
                               ""
                      )
)

write_rds(metrics, "metrics.rds")

dashboard_all <- read_rds(here("data","Dashboard_all.rds")) # Also at https://drive.google.com/open?id=1XqGRRjQaFMMVshgF0HhnL7Ch9lnxVEYD

dashboard_mry <- dashboard_all %>% 
    filter(str_detect("Monterey",countyname),
           year == yr) %>%
    mutate(cds = as.numeric(cds)) %>%
    mutate(cds = as.character(cds))

write_rds(dashboard_mry, "dashboard_mry.rds")


csi_all <- read_excel(here("data","essaassistancestudentgroup19.xlsx"), range = "A3:G9975")

csi_mry <- csi_all %>%
    filter( str_extract(cds, "[1-9]{1,2}") == 27,
            str_detect(AssistanceStatus2019, "CSI")) %>%
    mutate(cds = paste0(str_extract(cds, "[0-9]{1,7}"),"0000000"  ))

write_rds(csi_mry, "csi_mry.rds")


### Manipulate -----

elpi <- dashboard_mry %>%
    filter(ind == "elpi") %>%
    select(cds:countyname, elpi = currstatus)

A_G <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    mutate(ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
           ag_cte_perc = ag_cte*100/currdenom) %>%
    select(cds:countyname,ag_cte_perc) 
# Note, this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. 
# It is not possible to get the exact figure with the aggregate data available


AP <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    mutate(ap = (curr_prep_apexam/currdenom) %>% round2(3)*100) %>%
    select(cds:countyname,ap ) 
# Note this is percentage of cohort that passed TWO AP exams. PErcentage that passed a single one is not available on Dashboard

chronic <- dashboard_mry %>%
    filter(ind == "chronic",
           studentgroup == "ALL") %>%
    select(cds:countyname, chronic = currstatus) 

grad <- dashboard_mry %>%
    filter(ind == "grad",
           studentgroup == "ALL") %>%
    select(cds:countyname, grad = currstatus) 

susp <- dashboard_mry %>%
    filter(ind == "susp",
           studentgroup == "ALL",
           rtype == "D") %>%  # To only get districts and because elementary and high school have suspensions this is the initial key
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

# Local educational agencies looking for information about middle school dropouts can obtain information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)

## High School Drop out 

drop_vroom <- vroom("data/cohort5year1819.txt", .name_repair = ~ janitor::make_clean_names(., case = "upper_camel")) 


drop <- drop_vroom  %>% 
    mutate_at(vars(CohortStudents:DropoutRate), funs(as.numeric) ) %>%
    filter( ReportingCategory == "TA",
            CharterSchool =="No",
            Dass == "All") %>%
    mutate(cds = paste0(CountyCode,DistrictCode,SchoolCode)) %>%
    select(cds, DropoutRate)


## Expelled 

exp_vroom <- vroom("data/exp1718.txt",.name_repair = ~ janitor::make_clean_names(., case = "upper_camel")) 

exp <- exp_vroom %>%
    mutate_at(vars(CumulativeEnrollment:ExpulsionCountDefianceOnly), funs(as.numeric) ) %>%
    mutate(exp = (UnduplicatedCountOfStudentsExpelledTotal*1000/CumulativeEnrollment)%>% round2(3) )  %>%
    filter(ReportingCategory == "TA",
           AggregateLevel == "D2") %>%  # Charter included Yes/No
    mutate(cds = paste0(CountyCode,DistrictCode,SchoolCode)) %>%
    select(cds, exp)

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
    group_by(DistrictCode, DistrictName) %>%
    transmute(cred.rate.wt = weighted.mean(full_cred, FTE , na.rm = TRUE ),
           cds = paste0(DistrictCode,"0000000")) %>%
    ungroup() %>%
    distinct() %>%
    mutate(cred.rate.wt = cred.rate.wt %>% round2(3)*100)

## Reclass ----

reclass_vroom <- vroom("data/filesreclass19.txt", .name_repair = ~ janitor::make_clean_names(., case = "upper_camel"))


reclass <- reclass_vroom %>%
    group_by(District) %>%
    mutate(reclassified = sum(Reclass),
           ELenroll = sum(El)) %>%
    ungroup() %>%
    transmute(
           reclass_rate = (reclassified*100/ELenroll) %>% round2(1), 
           cds = paste0(str_sub(Cds,1,7),"0000000")  ) %>% 
    distinct()

### Combine all the dashboard files ----

indicators <- list(   susp,exp , math, ela, 
                      A_G, AP, chronic, elpi, grad, drop, reclass,
                      cred_rate) %>%
    reduce( left_join)


write_rds(indicators ,here("indicators.rds"))

### End -----
