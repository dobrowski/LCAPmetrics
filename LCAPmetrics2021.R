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

metrics <- tibble("priority_area" = c(rep("Conditions for Learning",5),rep("Pupil Outcomes",8), rep("Engagement",10) ) ,
                  "priorities" = c(rep("1. Basic",3),"2. Implement State Standards","7. Course Access", rep("4. Pupil Achievement*", 7), "8. Other Pupil Outcomes", rep("3. Parent Involvement",2), rep("5. Pupil Engagement*", 5), rep("6. School Climate*",3) ),
                  "metrics" = c("cred.rate.wt","Materials","GoodRepair","Standards","BroadCourse", #5
                                "math", "ela" ,"ag_cte_perc","elpi","reclass_rate", #10
                                "ap","EAP","outcomes_other", "ParentInput","UnduplicatedParentPart", #15
                                "Attendance","chronic","MSdropout","DropoutRate","grad", #20
                                "susp","exp","local_other"),
                  "source" = c(rep("Local Dashboard Data",1),
                               rep("Local Dashboard Data and  district Williams Report",2),
                               "LEA and site CCSS implementation plans and teacher participation in CCSS training.",
                               "student information systems",
                               rep("Dashboard",4),
                               "Dataquest",# https://www.cde.ca.gov/ci/gs/hs/eapindex.asp  doesn't exist, maybe in CCI?
                               "Dashboard",
                               "Dataquest",
                               "Local data",
                               rep("Local Dashboard Data and district and school surveys related to WASC and Single Plan Student Achievement, or DLAC/ELAC",1),
                               "Local Dashboard Data and local data on parent involvement in district/school activities (e.g., committees, student clubs, after school enrichment, fundraisers, carnivals, promotion activities, PTO membership)",
                               "student information systems",
                               "Dashboard",
                               rep("student information systems",2),
                               rep("Dashboard",2), 
                               "Dataquest", 
                               "Local Dashboard Data and from such sources as LEA plans, School Site Council activities, and English Learner Advisory Council materials"   ),
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
                  "notes" = c( "Please note this only looks at teachers and not adminstrators, pupil services, itinerant nor push-in/pull-out teachers. The most recent available public data is 2018-19. It is grouped at the district level, and is weighted by percent FTE.  It does not yet look at proper assignment of teachers, only credential status. Please also reference your Williams Report."  ,
                               rep("",4), #5
                               rep("It is recommended to use local data, such as interims or NWEA, rather than data from two years ago.",2),
                               "Please note this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. It is not possible to get the exact figure with the aggregate data available.  CALPADS Report 3.14, 3.15 and 15.1 may be helpful.", # just use the CCI indicator too. 
                               rep("",2), #10  #  Look at Title III AMOA 2  reporting
                               "Please note this is the percentage of the graduating cohort that passed TWO AP exams. The percentage of students that passed a single AP exam is not available on the Dashboard",  #  Look at AP data file,  also add link to College Board Online https://scores.collegeboard.org/pawra/home.action
                               rep("",2),  #  Remove EAP reference to dataquest.  https://www.cde.ca.gov/ci/gs/hs/eapindex.asp
                               "One possible example is a rating on a self-assessment tool.",
                               "Consider daily participation or weekly engagement records.", #15
                               "",
                               "CALPADS Report 14.1 and 14.2 may be helpful.", #17
                               "Please note LEAs can find middle school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)",
                               "",
                               "CALPADS Report 15.1 and 15.2 may be helpful.", #20
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


# chronic <- tbl(con, "DASH_CHRONIC") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear)) %>%
#     select(cds:countyname, chronic = currstatus) %>%
#     collect()  %>%
#     filter(str_detect(countyname,"Monterey"))


chronic <- pull.dash("DASH_CHRONIC","chronic")

# grad <- tbl(con, "DASH_GRAD") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear)) %>%
#     select(cds:countyname, grad = currstatus) %>%
#     collect()  %>%
#     filter(str_detect(countyname,"Monterey"))

grad <- pull.dash("DASH_GRAD","grad")


# susp <- tbl(con, "DASH_SUSP") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear),
#            rtype == "D") %>%  # To only get districts and because elementary and high school have suspensions this is the initial key
#     select(cds:countyname, susp = currstatus) %>%
#     collect()  %>%
#     filter(str_detect(countyname,"Monterey"))


susp <- pull.dash("DASH_SUSP","susp") %>%
    filter( rtype == "D")




# math <- tbl(con, "DASH_MATH") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear)) %>%
#     select(cds:countyname, math = currstatus)  %>%
#     collect()  %>%
#     filter(str_detect(countyname,"Monterey"))


math <- pull.dash("DASH_MATH","math")


# ela <- tbl(con, "DASH_ELA") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear)) %>%
#     select(cds:countyname, ela = currstatus)  %>%
#     collect()  %>%
#     filter(str_detect(countyname,"Monterey"))


ela <- pull.dash("DASH_ELA","ela")


elpi <- tbl(con, "DASH_ELPI") %>%
    select(cds:countyname, elpi = currstatus) %>%
    collect()

A_G <- tbl(con, "DASH_CCI") %>%
    filter(studentgroup == "ALL",
           reportingyear == max(reportingyear)) %>%
    mutate(ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
           ag_cte_perc = ag_cte*100/currdenom) %>%
    select(cds:countyname,ag_cte_perc,curr_prep_apexam,currdenom) %>%
    collect() %>%
    filter(str_detect(countyname,"Monterey")) %>%
    mutate(ap = (curr_prep_apexam/currdenom) %>% round2(3)*100)

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
           YEAR == max(YEAR)) %>%
    collect()    %>%
group_by(District) %>%
    mutate(reclassified = sum(Reclass),
           ELenroll = sum(EL)) %>%
    ungroup() %>%
    transmute(
        reclass_rate = (reclassified*100/ELenroll) %>% round2(1), 
        cds = paste0(str_sub(CDS,1,7),"0000000")  ) %>% 
    distinct() 

### Combine all the dashboard files ----

indicators <- list(   susp,exp , math, ela, 
                      A_G, # AP,
                      chronic, elpi, grad, drop, reclass,
                      cred_rate) %>%
    reduce( left_join)


indicators <- indicators %>%
    mutate(susp = scales::percent( susp/100 , accuracy = .1 ),
           cred.rate.wt = scales::percent( cred.rate.wt/100 , accuracy = .1 ),
           elpi = scales::percent( elpi/100 , accuracy = .1 ),
           reclass_rate = scales::percent( reclass_rate/100 , accuracy = .1 ),
           ap = scales::percent( ap/100 , accuracy = .1 ),
           chronic = scales::percent( chronic/100 , accuracy = .1 ),
           grad = scales::percent( grad/100 , accuracy = .1 ),
           Dropout_Rate = scales::percent( Dropout_Rate/100 , accuracy = .1 ),
           ag_cte_perc = scales::percent( ag_cte_perc/100 , accuracy = .1 )
           
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
