# Instructions for updating in future years. 
# Update the "Dashboard_all.rds" file from Dashboard Rproject
# Fix the CSI list
# Update the Metrics.csv for most current year, additional notes and if sources change. 


### Load libraries -----
# remotes::install_github("dobrowski/MCOE")
library(tidyverse)
library(googlesheets4)
library(here)
library(vroom)
library(readxl)
library(glue)
library(MCOE) # Toggle this on an off.  It doesn't work on shiny with this enabled

yr <- 2025

options(scipen = 999)


con <- mcoe_sql_con()



charter.school.codes <- c(
    "0112177", # Monterey Bay Charter
    "0116491", # Open Door Charter
    "0124297", # Bay View Academy
    "2730232" , # Home Charter
    "6119663", # Oasis
    "2730240", # Learning for Life
    "6118962", # International School
    "0118349" # Big Sur Charter
) 


# Used to avoid duplication of school and district for Red Indicators 
single.school.codes <- c(
    "27659790000000"	,#	Bradley Union Elementary
    "27659956026082"	,#	Chualar Union
    "27660276026108"	,#	Graves Elementary
    "27660760000000"	,#	Lagunita Elementary
    "27660846026157"	,#	Mission Union Elementary
    "27661676026629"	,#	San Antonio Union Elementary
    "27661756026637"	,#	San Ardo Union Elementary
    "27661836026645"	,#	San Lucas Union Elementary
    "27751500000000"	#	Big Sur Unified
)






### Import data -------

icon.df <- read.csv("icons.csv")


write_rds(icon.df, "icons.rds")


metrics <- read_csv("metrics.csv") %>%
    mutate(notes = replace_na(notes, ""))


mid.year.resources <- read_sheet("https://docs.google.com/spreadsheets/d/1rP9rp1w__o84QGq9alAygWeFXXRfa72W2krN0DTFK6c/edit?gid=0#gid=0")

write_rds(mid.year.resources, "mid_year_resources.rds")

### Initial creation, now just import ----- 


# metrics <- tibble("priority_area" = c(rep("Conditions for Learning",8),rep("Pupil Outcomes",10), rep("Engagement",11) ) ,
#                   "priorities" = c(rep("1. Basic",3),rep("2. Implement State Standards",2),rep("7. Course Access",3), rep("4. Pupil Achievement*", 9), "8. Other Pupil Outcomes", rep("3. Parent Involvement",3), rep("5. Pupil Engagement*", 5), rep("6. School Climate*",3) ),
#                   "metrics" = c("cred.rate.wt","Materials","GoodRepair","Standards", "StandardsEL" , #5
#                                 "BroadCourse", "CourseUndup", "CourseSWD" , #8
#                                 "math", "ela" ,"ag_cte_perc", "ag_perc" , "cte_perc" ,"elpi","reclass_rate", #13
#                                 "ap_perc","eap","outcomes_other", "ParentInput","UnduplicatedParentPart", "ParentSWD", #19
#                                 "Attendance","chronic","MSdropout","DropoutRate","grad", #23
#                                 "susp","exp","local_other"),
#                   "source" = c(rep("Local Dashboard Data",1),
#                                rep("Local Dashboard Data and  district Williams Report",2),
#                                "LEA and site CCSS implementation plans and teacher participation in CCSS training.",
#                                "LEA and site CCSS and ELD implementation plans and teacher participation in CCSS and ELD training.", #5
#                                rep("student information systems", 3),
#                                rep("Dashboard",2),#10
#                                rep("Dashboard",1),
#                                rep("Dashboard",3), 
#                                "Dataquest",#15 # https://www.cde.ca.gov/ci/gs/hs/eapindex.asp  doesn't exist, maybe in CCI? 
#                                "Dashboard",
#                                "CAASPP results",
#                                "Local data",
#                                "Local Dashboard Data and district and school surveys related to WASC and Single Plan Student Achievement, or DLAC/ELAC",
#                                rep("Local Dashboard Data and local data on parent involvement in district/school activities (e.g., committees, student clubs, promotion activities, PTO membership, etc.)",2),#20
#                                "student information systems",
#                                "Dataquest",
#                                rep("student information systems",2),
#                                "Dataquest", #25
#                                "Dataquest", 
#                                "Dataquest", 
#                                "Local Dashboard Data and from such sources as LEA plans, School Site Council activities, and English Learner Advisory Council materials"   ),
#                   "description" = c("Teaching Assingments are 'Clear' for credientially and apprioriately assigned", 
#                                     "Standards-aligned Instructional Materials for every student",
#                                     "School Facilities in “Good Repair” per CDE’s Facility Inspection Tool (FIT)",
#                                     "implementation of all CA state standards for all students", 
#                                     "implmentation of how ELs will access the CCSS and ELD standards", #5
#                                     "students have access and are enrolled in a broad course of study (Social Science, Health, VAPA, Science, PE, World Language)", 
#                                     "students have access and are enrolled in programs and services developed and provided to low income, English learner and foster youth pupils",
#                                     "students have access and are enrolled in programs and services developed and provided to students with disabilities", #8
#                                     
#                                     "State CAASPP assessments (Math DFS)", 
#                                     "State CAASPP assessments (ELA DFS)", 
#                                     "percent of pupils that have successfully completed both A-G courses and CTE courses", 
#                                     "percent of pupils that have successfully completed A-G courses", 
#                                     "percent of pupils that have successfully completed CTE courses", 
#                                     "percent of ELs who progress in English proficiency (ELPAC)",
#                                     "EL reclassification rate", #13
#                                     "percent of pupils that pass AP exams with a score of 3 or higher",
#                                     "pupils prepared for college by the EAP (ELA/Math CAASPP Score of 3 or higher)",
#                                     "outcomes for subjects listed in course access" ,
#                                     "parent input in decision-making",
#                                     "Parental Participation in programs for Unduplicated Pupils (UPs)", #18
#                                     "Parental Participation in programs for Students with Disabilities", 
#                                     "attendance rates", 
#                                     "Chronic Absenteeism rates", 
#                                     "Middle school dropout rates", 
#                                     "High school dropout rates", 
#                                     "High school graduation rates", #24
#                                     "Suspension rates", 
#                                     "Expulsion rates", 
#                                     "other local measures (Surveys regarding safety and school connectedness)"
#                   ),
#                   "website" = c("Teaching Assingment Monitoring Outcomes at https://www.cde.ca.gov/ds/ad/tamo.asp",
#                                 rep("",7), #5
#                                 rep("Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/dashboardresources.asp?tabsection=3",2),
#                                 
#                                 rep("Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/dashboardresources.asp?tabsection=3",3),
#                                 "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/dashboardresources.asp?tabsection=3",
#                                 "https://www.cde.ca.gov/ds/ad/filesreclass.asp", #10
#                                 "Dashboard Datafiles at https://www.cde.ca.gov/ta/ac/cm/dashboardresources.asp?tabsection=3",
#                                 "caaspp-elpac.cde.ca.gov",
#                                 rep("",5), #16
#                                 "https://www.cde.ca.gov/ds/ad/filesabd.asp",
#                                 "",
#                                 "https://www.cde.ca.gov/ds/ad/filesacgr.asp",
#                                 "https://www.cde.ca.gov/ds/ad/filesacgr.asp", #20
#                                 "https://www.cde.ca.gov/ds/ad/filessd.asp",
#                                 "https://www.cde.ca.gov/ds/ad/filesed.asp",
#                                 rep("",1)
#                   ),
#                   "year" = c("2020-21",
#                              rep("",7), #5
#                              rep("2021-22",2),
#                              rep("2020-21",3),
#                              "2021-22",
#                              "2020-21", #10
#                              "2020-21",
#                              "2021-22",
#                              rep("",5), #16
#                              "2020-21",
#                              "",
#                              rep("2020-21",4),
#                              rep("",1)
#                     
#                   ),
#                   "notes" = c( ""  ,
#                                rep("",7), #5
#                                rep("",2),
#                                 # just use the CCI indicator too. 
#                                rep("Note 2020-21 data is available on the Dashboard Additional Reports.",3), # just use the CCI indicator too. 
#                                rep("",2), #10  #  Look at Title III AMOA 2  reporting
#                                "Note 2020-21 data is available on the Dashboard Additional Reports. Please note this is the percentage of the graduating cohort that passed TWO AP exams. The percentage of students that passed a single AP exam is not available on the Dashboard. Please also look at College Board Online https://scores.collegeboard.org/pawra/home.action",  #  Look at AP data file,  also add link to College Board Online https://scores.collegeboard.org/pawra/home.action
#                                "",
#                                rep("",4),  #   https://www.cde.ca.gov/ci/gs/hs/eapindex.asp
#                            
#                                "Consider daily participation or weekly engagement records.", #15
# 
#                                "CALPADS Report 14.1 and 14.2 may be helpful.", #17
#                                "Please note LEAs can find middle school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)",
#                                "Please note LEAs can find high school dropouts information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades nine through twelve)",
#                                "CALPADS Report 15.1 and 15.2 may be helpful.", #20
#                                "CALPADS Report 7.10 and 7.12 may be helpful.",
#                                "Please note this is a rate per thousand students.",
#                                ""
#                   )
# ) %>% 
#     arrange(priorities)

write_rds(metrics, "metrics.rds")


# write_excel_csv(metrics,"metrics.csv")

### Dashboard -------

dashboard_mry <- tbl(con, "DASH_ALL") %>%
     filter(countyname == "Monterey",
            rtype == "D" | charter_flag == "Y",
            reportingyear == (yr -1) 
    ) %>%  
    collect()  


# dashboard_mry <- sunshine(dashboard_mry)


write_rds(dashboard_mry, "dashboard_mry.rds")

# This generates the LCAP Reds from 2023 but now just read the file.
# 
lcap.reds <- tbl(con, "DASH_ALL") %>%
    filter(countyname == "Monterey",
           reportingyear == (2023),
           color == 1 | (indicator == "CCI" & statuslevel == 1 & currnsizemet == "Y" ),
           #       !is.na(currnsizemet)
    ) %>%
    collect()  %>%
    filter(cds %notin% single.school.codes) %>% # To Avoid duplication on Single School Districts
    mutate(schoolname = replace_na(schoolname, "Districtwide"),
           districtname = if_else(!is.na(charter_flag), schoolname, districtname),
           ) %>%
    select(cds, districtname, schoolname,
           studentgroup ,
           studentgroup.long, indicator, currstatus) %>%
    arrange(indicator, studentgroup.long, schoolname)
# 
# 
# # lcap.reds <- sunshine(lcap.reds)
# 
# write_rds(lcap.reds, "lcap_reds.rds")


cds.dist <- indicators %>%
    select(cds,districtname)

clipr::write_clip(cds.dist)

# 
# lcap.reds.pivot <- lcap.reds %>% 
#     select(districtname, studentgroup.long, schoolname, indicator) %>%
#     # Pivots to have indicator columns with lists of schools 
#     pivot_wider(names_from =  indicator,
#                 values_from = schoolname
#     ) %>% 
#     rowwise() %>% 
#     # collapses the list columns to a string for the list of schools 
#     mutate(across(c(ELA, CHRO, MATH, SUSP, CCI, ELPI, GRAD ),  ~ paste(.x, collapse=', ') )
#     ) %>%
#     ungroup() %>%
#     left_join(cds.dist)
# 
# 
# 
# write_rds(lcap.reds.pivot, "lcap_reds_pivot.rds")



# Add 2024 status to the graphs 

lcap.reds2024 <- tbl(con, "DASH_ALL") %>%
    filter(countyname == "Monterey",
           reportingyear == (2024),
           # color == 1 | (indicator == "CCI" & statuslevel == 1 & currnsizemet == "Y" ),
           #       !is.na(currnsizemet)
    ) %>%  
    collect() %>%
    select(cds, studentgroup, indicator, status2024 = currstatus, color2024 = color)


#lcap.reds <- read_rds("lcap_reds.rds")

lcap.reds2024.joint <- lcap.reds %>%
    rename(status2023 = currstatus) %>%
    left_join(lcap.reds2024) %>%
    mutate(difference =  round2(  status2023 - status2024, 1) )

# write_sheet(lcap.reds2024.joint, "https://docs.google.com/spreadsheets/d/1-pibQDT9uAhU8uYGJeKSeE2gez3_pW8wBTzw4PKCBIU/edit?gid=0#gid=0")

write_rds(lcap.reds2024.joint,"lcap_reds_into_2024.rds")




### LREBG -------




dir <- tbl(con, "SCHOOL_DIR") %>%
    collect() %>%
    select(cds_code, soc_type, eil_code)


lrebg.hs.chron <- tbl(con, "CHRONIC") %>%
    filter(county_code == 27,
           academic_year == "2023-24",
           reporting_category == "TA",
           aggregate_level == "S")  %>%  
 #   head(20) %>%
    collect() %>%
    mutate(cds_code = paste0(county_code, district_code, school_code)) %>%
    left_join(dir) %>%
    filter(eil_code == "HS",
           chronic_absenteeism_rate >= 10,
           !str_detect(school_name,"El Puente")) %>%
    mutate(studentgroup = "ALL", 
           studentgroup.long = "All Students",
           indicator = "CHRO"  ) %>%
    select(cds = cds_code, 
       studentgroup, 
       studentgroup.long,
       indicator, 
       districtname = district_name,
       schoolname = school_name, 
       rtype = aggregate_level, 
       currstatus = chronic_absenteeism_rate)
    


lrebg <- tbl(con, "DASH_ALL") %>%
    filter(countyname == "Monterey",
           reportingyear == (2024),
           statuslevel %in% c(1,2),
           indicator %in% c("ELA","MATH","CHRO"),
           rtype == "D" | (rtype == "S" & studentgroup == "ALL" )
           # color == 1 | (indicator == "CCI" & statuslevel == 1 & currnsizemet == "Y" ),
           #       !is.na(currnsizemet)
    ) %>%  
    collect() %>%
    filter(cds %notin% single.school.codes) %>% # To Avoid duplication on Single School Districts
    mutate(schoolname = replace_na(schoolname, "Districtwide"),
           districtname = if_else(!is.na(charter_flag), schoolname, districtname),
    ) %>%
    select(cds, studentgroup, studentgroup.long , indicator, districtname, schoolname,  rtype, statuslevel, currstatus, changelevel  , change , color) %>%
    filter(studentgroup != c("SBA","CAA" )) %>%
    arrange(districtname, rtype, indicator ,studentgroup.long) %>%
    mutate(lrebg = "lrebg") %>%
    bind_rows(lrebg.hs.chron)  %>%
    mutate(statuslevel = case_when(indicator == "ELA" & statuslevel == 1 ~ "Very Low",
                                   indicator == "ELA" & statuslevel == 2 ~ "Low",
                                   indicator == "MATH" & statuslevel == 1 ~ "Very Low",
                                   indicator == "MATH" & statuslevel == 2 ~ "Low",
                                   indicator == "CHRO" & statuslevel == 1 ~ "Very High",
                                   indicator == "CHRO" & statuslevel == 2 ~ "High"),
           
           changelevel = case_when(indicator == "ELA" & changelevel == 1 ~ "Declined\nSignificantly",
                                   indicator == "ELA" & changelevel == 2 ~ "Declined",
                                   indicator == "ELA" & changelevel == 3 ~ "Maintained",
                                   indicator == "ELA" & changelevel == 4 ~ "Increased",
                                   indicator == "ELA" & changelevel == 5 ~ "Increased\nSignificantly",
                                   
                                   indicator == "MATH" & changelevel == 1 ~ "Declined\nSignificantly",
                                   indicator == "MATH" & changelevel == 2 ~ "Declined",
                                   indicator == "MATH" & changelevel == 3 ~ "Maintained",
                                   indicator == "MATH" & changelevel == 4 ~ "Increased",
                                   indicator == "MATH" & changelevel == 5 ~ "Increased\nSignificantly",
                                   
                                   indicator == "CHRO" & changelevel == 5 ~ "Declined\nSignificantly",
                                   indicator == "CHRO" & changelevel == 4 ~ "Declined",
                                   indicator == "CHRO" & changelevel == 3 ~ "Maintained",
                                   indicator == "CHRO" & changelevel == 2 ~ "Increased",
                                   indicator == "CHRO" & changelevel == 1 ~ "Increased\nSignificantly"
           )
                     
                                   
           )


# Add sentence about sTstatus not color from 5x5 




write_rds(lrebg,"lrebg.rds")



lcap.reds.lrebg <- lcap.reds2024.joint %>%
    left_join(lrebg)


write_rds(lcap.reds.lrebg, "lcap_reds_into_2024.rds")




# LREBG Funds 

lrebg.funds <- read_xlsx(here("data", "LREBG Interim Expenditure Data - LEAs Within Monterey COE With Outstanding Funds as of 01.20.25.xlsx"),
                         skip = 1)  %>%
    rename(cds = `CDS Code`, dist.name = `LEA Name`, balance = `Cash Balance`)
    


write_rds(lrebg.funds, "lrebg_funds.rds")




### CSI ------

csi_all <- read_excel(here("data","essaassistance24.xlsx"), 
                      sheet = "2024-25 ESSA State Schools",
                      range = "A3:AK10043")

csi_mry <- csi_all %>%
    filter( str_extract(cds, "[1-9]{1,2}") == 27,
            str_detect(AssistanceStatus2024, "CSI")) %>%
    mutate(cds = paste0(str_extract(cds, "[0-9]{1,7}"),"0000000"  )) # This will need to be updated in future years for charter CSI



# csi_mry <- sunshine(csi_mry)

write_rds(csi_mry, "csi_mry.rds")


### Equity Multiplier -----


# Updated for 2024-25 


em_all <- read_excel(here("data","lcffem24p1.xlsx"), 
                      sheet = "24–25 P-1 LCFF EM School Data",
                      range = "A4:R10167") %>%
    janitor::clean_names("snake")

em_mry <- em_all %>%
    filter( county_code == 27,
            str_detect(lcff_equity_multiplier_eligibility_determination_if_c_1_through_c_3_true_true_c_4, "TRUE")) %>%
    mutate(cds = paste0(county_code, district_code,"0000000"  )) # This will need to be updated in future years for charter Equity Multiplier

write_rds(em_mry, "em_mry.rds")




### DA -----

# This code calculates DA on its own.  Use if the official list is not available 

# dash.mry <- tbl(con,"DASH_ALL_2022") %>%
#     filter(countyname == "Monterey",
#            rtype == "D" | charter_flag == "Y"
#            #           cds == dist
#            ) %>%
#     collect () %>%
#     mutate(indicator2 = recode(indicator,
#                                "ela" = "CAASPP English Language Arts (ELA)",
#                                "math" = "CAASPP Math",
#                                "elpi" = "English Learner Progress Indicator (ELPI)",
#                                "grad" = "Graduation Rate",
#                                "chronic" = "Chronic Absenteeism",
#                                "susp" = "Suspension Rate"
#     ))
# 
# 
# 
# da.list <- dash.mry  %>%
#     select(districtname, studentgroup, statuslevel, indicator) %>%
#     pivot_wider(id_cols = c(districtname,studentgroup),
#                 names_from = indicator,
#                 values_from = statuslevel
#     ) %>%
#     transmute(districtname, 
#               studentgroup,
#               priority4 = case_when(ela == 1 & math == 1 ~ TRUE,
#                                     elpi == 1 ~ TRUE,
#                                     TRUE ~ FALSE),
#               priority5 = case_when(grad == 1 ~ TRUE,
#                                     chronic == 1 ~ TRUE,
#                                     TRUE ~ FALSE),
#               priority6 = case_when(susp == 1 ~ TRUE,
#                                     TRUE ~ FALSE),
#               DA.eligible  = case_when(priority4+priority5+priority6 >=2 ~ "DA",
#                                        TRUE ~ "Not")
#     )
# 
# dash.mry.da <- left_join(dash.mry, da.list) %>%
#     filter(DA.eligible == "DA",
#            statuslevel == 1)



dash.mry.da.2 <- read_excel(here("data","assistancestatus24.xlsx"),
                            range = "A6:AD999",
                            sheet = "District and COE 2024") %>%
    filter(Countyname == "Monterey") %>%
    pivot_longer(cols = ends_with("priorities")) %>%
    mutate(indicator2 = case_when(value == "A" ~ "Met Criteria in Priority Areas 4 (Academic Indicators), 5 (Chronic Absenteeism and/or Graduation), and 6 (Suspensions)",
                                    value == "B" ~ "Met Criteria in Priority Areas 4 (Academic Indicators) and 5 (Chronic Absenteeism and/or Graduation)",
                                    value == "D" ~ "Met Criteria in Priority Areas 4 (Academic Indicators) and 6 (Suspensions)",
                                    value == "C" ~ "Met Criteria in Priority Areas 5 (Chronic Absenteeism and/or Graduation) and 6 (Suspensions)",
                                  value =="E" ~ 	"Met Criteria in Priority Areas 4 (Academic Indicators) and 8 (College/Career)",
                                  value =="F" ~ 	"Met Criteria in Priority Areas 5 (Chronic Absenteeism and/or Graduation) and 8 (College/Career)",
                                  value =="G" ~ 	"Met Criteria in Priority Areas 6 (Suspensions) and 8 (College/Career)",
                                  value =="H" ~ 	"Met Criteria in Priority Areas 4 (Academic Indicators), 5 (Chronic Absenteeism and/or Graduation), and 8 (College/Career)",
                                  value =="I" ~ 	"Met Criteria in Priority Areas 4 (Academic Indicators), 6 (Suspensions), and 8 (College/Career)",
                                  value =="J" ~ 	"Met Criteria in Priority Areas 5 (Chronic Absenteeism and/or Graduation), 6 (Suspensions), and 8 (College/Career)",
                                  value =="K" ~ 	"Met Criteria in Priority Areas 4 (Academic Indicators), 5 (Chronic Absenteeism and/or Graduation), 6 (Suspensions), and 8 (College/Career)"
                                    ),
           studentgroup.long = case_when(name == "AApriorities"	~ "Black/African American",
                                         name == "AIpriorities" ~	"American Indian or Alaska Native American",
                                         name == "ASpriorities" ~	"Asian American",
                                         name == "ELpriorities" ~	"English Learner",
                                         name == "LTELpriorities" ~	"Long Term English Learner",
                                         name == "FIpriorities" ~	"Filipino",
                                         name == "FOSpriorities"	 ~ "Foster Youth",
                                         name == "HIpriorities" ~	"Hispanic",
                                         name == "HOMpriorities"	~ "Homeless",
                                         name == "PIpriorities" ~	"Pacific Islander",
                                         name == "SEDpriorities" ~	"Socioeconomically Disadvantaged",
                                         name == "SWDpriorities" ~	"Students with Disabilities",
                                         name == "TOMpriorities" ~	"Two or More Races",
                                         name == "WHpriorities" ~	"White"
           ),
           cds = CDS
    )



# sun.dash.da <- dash.mry.da.2 %>%
#     filter(str_detect(LEAname, "Alisal")) %>%
#     mutate(LEAname = "Sunshine Union",
#            cds = "99999990000000")
# 
# 
# dash.mry.da.2 <- dash.mry.da.2 %>%
#     bind_rows(sun.dash.da)
# 


write_rds(dash.mry.da.2,"dash_mry_da.rds")

### Manipulate -----


# pull.dash <- function(tablename, col){
#         tbl(con, tablename) %>%
#         filter(studentgroup == "ALL",
#                reportingyear == max(reportingyear)) %>%
#         select(cds:countyname, charter_flag, currstatus)  %>%
#         collect()  %>%
#         filter(str_detect(countyname,"Monterey")) %>%
#         rename(!!col := currstatus)   # Note the :=  because of passing string to left side of argument
# }

pull.dash <- function(ind, col){
        dashboard_mry %>%
        mutate(studentgroup = if_else(indicator == "ELPI" & studentgroup == "EL",  "ALL", studentgroup)) %>%
        filter(studentgroup == "ALL",
               indicator == ind) %>%
        select(cds:countyname, charter_flag, currstatus)  %>%
        rename(!!col := currstatus)   # Note the :=  because of passing string to left side of argument
}


temp <- dashboard_mry %>%
    filter(indicator == "ELPI")


chronic <- pull.dash("CHRO","chronic")

grad <- pull.dash("GRAD","grad")

susp <- pull.dash("SUSP", "susp")

math <- pull.dash("MATH","math")

ela <- pull.dash("ELA","ela")

elpi <- pull.dash("ELPI","elpi")


caaspp.full <- tbl(con, "CAASPP") %>%
    filter(subgroup_id == "1",
           test_year == (yr -1),
           county_code == "27",
           school_code %in% c("0000000",charter.school.codes),
           grade == "13") %>%  
    select(county_code:test_id, percentage_standard_met_and_above) %>%
    collect()  


caaspp <- caaspp.full %>%
    mutate(cds = paste0(county_code,district_code,school_code),
           percentage_standard_met_and_above = as.numeric(percentage_standard_met_and_above)
    ) %>%
    select(cds, test_id ,percentage_standard_met_and_above) %>%
    pivot_wider(names_from = test_id, values_from = percentage_standard_met_and_above ) %>%
    na.omit() %>%
    mutate(caaspp = glue("{round(`1`,1)}% in ELA and {round(`2`,1)}% in Math") ) %>%
    select(cds,caaspp)



cast.full <- tbl(con, "CAST") %>%
    filter(demographic_id == "1",
           test_year == (yr -1),
           county_code == "27",
           school_code %in% c("0000000",charter.school.codes),
           grade == "13") %>%  
    collect()  


cast <- cast.full %>%
    transmute(cds = paste0(county_code,district_code,school_code),
           science = as.numeric(percentage_standard_met_and_above)
    ) # %>%
   # na.omit() 








# elpi <- tbl(con, "DASH_ELPI") %>%
#     filter(reportingyear == max(reportingyear)) %>%
#     select(cds:countyname, charter_flag, elpi = currstatus) %>%
#     collect() %>%
#     filter(str_detect(countyname,"Monterey")) 


# Holding place for new A-G Dashboard report in late January 2023

# A_G <- tbl(con, "DASH_CCI") %>%
#     filter(studentgroup == "ALL",
#            reportingyear == max(reportingyear),
#            countyname == "Monterey",
#            rtype == "D" | rtype == "S" & charter_flag == "Y" 
#            ) %>%
#     mutate(# ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
#            # ag_cte_perc = ag_cte*100/currdenom ,
#            ag_perc = ag_pct ,
#            cte_perc = cte_pct ,
#            ag_cte_perc = ag_cte_pct,
#            ap_perc = ap_pct ,
#            )  %>%
#     collect() %>%
#   select(cds, ends_with("perc"))

# Based on Dashboard additional report UC/CSU and CTE Met
A_G <- read_sheet("https://docs.google.com/spreadsheets/d/1aX3sSlrWsOSyd9lzjME_fppAEbZE0EiXDkdYgygseAY/edit#gid=0",
                  sheet = "2024 Dashboard") %>%
    mutate(cds = as.character(cds))



# Note, this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. 
# It is not possible to get the exact figure with the aggregate data available


AP <- dashboard_mry %>%
    filter(indicator == "CCI",
           studentgroup == "ALL") %>%
    mutate(ap_perc = (curr_prep_apexam/currdenom) %>% round2(3)*100) %>%
    select(cds,ap_perc )
# Note this is percentage of cohort that passed TWO AP exams. PErcentage that passed a single one is not available on Dashboard



## EAP 
# % at level 3 on Math  ;  % at level 3 on ELA 

eap.full <- tbl(con, "CAASPP") %>%
    filter(subgroup_id == "1",
           test_year == (yr -1),
           county_code == "27",
           school_code %in% c("0000000",charter.school.codes),
           grade == "11") %>%  
    select(county_code:test_id, eap = percentage_standard_met_and_above) %>%
    collect()  


eap <- eap.full %>%
    mutate(cds = paste0(county_code,district_code,school_code),
           eap = as.numeric(eap)
           ) %>%
    select(cds, test_id ,eap) %>%
    pivot_wider(names_from = test_id, values_from = eap ) %>%
    na.omit() %>%
    mutate(eap = glue("{round(`1`,1)}% in ELA and {round(`2`,1)}% in Math") ) %>%
    select(cds,eap)



## Middle Drop out

# Local educational agencies looking for information about middle school dropouts can obtain information from CALPADS snapshot report 1.14: Dropouts Count – State View (filtered for grades seven and eight)

## High School Drop out 


drop <- tbl(con, "GRAD_FOUR")  %>% 
    filter( reporting_category == "TA",
            charter_school =="No",
            dass == "All",
            county_name == "Monterey",
            academic_year == max(academic_year)) %>%
    collect() %>%
    mutate(cds = paste0(county_code,district_code,school_code)) %>%
     select(cds, dropout_rate) 



## Expelled 


exp <- tbl(con, "EXP")  %>%
#    mutate_at(vars(CumulativeEnrollment:ExpulsionCountDefianceOnly), funs(as.numeric) ) %>%
    filter(county_name == "Monterey",
           reporting_category == "TA",
           academic_year == max(academic_year),
           aggregate_level == "D" & charter_yn == "No" | aggregate_level == "S" & charter_yn == "Yes" 
           ) %>%  # Charter included Yes/No
    collect() %>%
    mutate(exp = (unduplicated_count_of_students_expelled_total*1000/cumulative_enrollment)%>% round2(3) )  %>%
    mutate(cds = paste0(county_code,district_code,school_code))  %>%
    select(cds, exp)







## Credential Teachers

# % of teachers fully credentialed AND % of teachers appropriately assigned within their credential area (2 figures)
# 
# % of teachers who are BOTH fully credentialed and appropriately assigned. (if they are PIP, STIP, etc. they wouldn’t be in this count)


# # This should be replaced with the TAMO tables 
# 
# cred <-  tbl(con, "STAFF_CRED") %>%
#     filter(AcademicYear == max(AcademicYear)) %>%
#     select(RecID, CredentialType) %>%
#     distinct()
# 
# staff.mry <- tbl(con, "STAFF_SCHOOL_FTE") %>%
#     filter(CountyName =="Monterey",
#            JobClassification == "12",
#            AcademicYear == max(AcademicYear)) %>%  # Only teachers and not 10 = Administrator c("11 = Pupil services", "12 = Teacher", "25 = Non-certificated Administrator", "26 = Charter School Non-certificated Teacher", "27 = Itinerant or Pull-Out/Push-In Teacher")
#     select(-FileCreated, -YEAR, -AcademicYear) %>%
#     left_join(cred)  %>%
#  #   mutate(full_cred = if_else(CredentialType == "10", TRUE, FALSE)) %>% 
#     collect() %>%
#     mutate(full_cred = if_else(CredentialType == "10", TRUE, FALSE)) 
# 
# 
# 
# 
# cred_rate <- staff.mry %>%
#     group_by(DistrictCode, DistrictName) %>%
#     transmute(cred.rate.wt = weighted.mean(full_cred, FTE , na.rm = TRUE ),
#               cds = paste0(DistrictCode,"0000000")) %>%
#     ungroup() %>%
#     distinct() %>%
#     mutate(cred.rate.wt = cred.rate.wt %>% round2(3)*100)



cred_rate <- tbl(con, "Teaching") %>%
    filter(Academic_Year == max(Academic_Year),
           County_Code == 27,
     #    #   Aggregate_Level %in% c("D", "S" ),
            Subject_Area == "TA",
            Teacher_Experience_Level == "ALL",
     #       DASS == "ALL",
     #       School_Grade_Span == "ALL",
            Teacher_Credential_Level == "ALL",
     # #      Charter_School %in% c("No","Yes") 
            ) %>%
    collect()  %>%
    filter(  ( Aggregate_Level == "D" &  Charter_School == "N" & DASS == "ALL" & School_Grade_Span == "ALL") |
              ( Aggregate_Level == "S" &  Charter_School == "Y"   ) 
            ) %>%
    mutate(
           School_Code = str_replace(School_Code,"NULL" ,"0000000"),
           School_Name = if_else(School_Name == "NULL", District_Name, School_Name)
           ) %>%
    transmute( cds = paste0(County_Code,as.character(District_Code),School_Code),
           cred.rate.wt = Clear_FTE_percent
           ) 




## Reclass ----


ent.list <- susp %>%
    select(-susp)






reclass.full  <- tbl(con, "RECLASS") %>%
    filter(County =="Monterey",
   #        YEAR == max(YEAR)
           ) %>%
    collect()  %>%
    left_join(ent.list, by = c("CDS" = "cds"))
    

reclass.charter <-  reclass.full %>%
    filter(charter_flag == "Y") %>%
    mutate(reclassified = Reclass,
           ELenroll = EL,
           cds = CDS) %>%
    select(YEAR, District = School, cds, reclassified, ELenroll) %>%
    distinct() %>%
    mutate(YEAR = case_when(YEAR == max(YEAR) ~ "new",
                            YEAR ==  max( YEAR[YEAR!=max(YEAR)] ) ~ "new_minus_one",  # Reclass rate is calculated by RFEPs in a given year divided by total EL in previous year
                            TRUE ~ "old"))  %>%
    filter(YEAR != "old"  ) %>%
    pivot_wider(values_from = c("reclassified", "ELenroll"), names_from = "YEAR") %>%
    transmute(cds,
              reclass_rate = (reclassified_new*100/ELenroll_new_minus_one)# %>% round2(1) 
              ) 


reclass <-  reclass.full %>%
        filter(is.na(charter_flag)) %>%
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
        reclass_rate = (reclassified_new*100/ELenroll_new_minus_one) %>% round2(1) ) %>%
     bind_rows(reclass.charter)

### Combine all the dashboard files ----





indicators <- list(   susp, exp , math, ela, 
                      caaspp, cast,
                      A_G, eap,  AP,
                      chronic, elpi, grad, drop, 
                      #reclass,
                      cred_rate) %>%
    reduce( left_join)

indicators <- indicators %>%
    filter(rtype == "D" | charter_flag == "Y") %>%
    mutate(susp = scales::percent( susp/100 , accuracy = .1 ),
           cred.rate.wt = scales::percent( cred.rate.wt/100 , accuracy = .1 ),
           science = scales::percent( science/100 , accuracy = .1 ),
           elpi = scales::percent( elpi/100 , accuracy = .1 ),
   #        reclass_rate = scales::percent( reclass_rate/100 , accuracy = .1 ),
           ap_perc = scales::percent( ap_perc/100 , accuracy = .1 ),
           ag_perc = scales::percent( ag_perc/100 , accuracy = .1 ),
           cte_perc = scales::percent( cte_perc/100 , accuracy = .1 ),
           chronic = scales::percent( chronic/100 , accuracy = .1 ),
           grad = scales::percent( grad/100 , accuracy = .1 ),
           dropout_rate = scales::percent( dropout_rate/100 , accuracy = .1 ),
           ag_cte_perc = scales::percent( ag_cte_perc/100 , accuracy = .1 ),
           districtname = ifelse(is.na(charter_flag), districtname, schoolname)
           
           
           )


# # sunshine <- function(df) {
#     
# 
# sun.df <- df %>%
#     filter(str_detect(districtname, "Alisal")) %>%
#     mutate(districtname = "Sunshine Union",
#            cds = "99999990000000")
# 
# 
# df %>%
#     bind_rows(sun.df)
# 
# }
# # indicators <- sunshine(indicators)


write_rds(indicators ,here("indicators.rds"))


### Unduplicated Count -------

undup.count.full <- tbl(con, "UPC") %>%
    filter(academic_year == max(academic_year),
           county_code == "27",
           #school_code == "0000000"
           ) %>%
    collect() 



undup.charter <- undup.count.full %>%
    filter(charter_school_y_n == "Yes") %>%
    transmute(undup.perc = calpads_unduplicated_pupil_count_upc/total_enrollment,
              cds = glue('{county_code}{district_code}{school_code}') )
    
    
undup.count <- undup.count.full %>%
    filter(charter_school_y_n == "No") %>%
    group_by(county_code,district_code) %>%
    transmute(undup.perc = sum(calpads_unduplicated_pupil_count_upc)/sum(total_enrollment),
              cds = glue('{county_code}{district_code}0000000') ) %>%
    ungroup() %>%
    select(undup.perc, cds) %>%
    distinct() %>%
    bind_rows(undup.charter)




undup.count <- undup.count %>%
    filter(cds == "27659610000000") %>%
    mutate(cds = "99999990000000") %>%
    bind_rows(undup.count)


write_rds(undup.count ,here("undup.rds"))




el.charter <- undup.count.full %>%
    filter(charter_school_y_n == "Yes") %>%
    transmute(el.count = english_learner_el,
        el.perc = english_learner_el/total_enrollment,
              cds = glue('{county_code}{district_code}{school_code}') ) %>%
    distinct()


el.count <- undup.count.full %>%
    filter(charter_school_y_n == "No") %>%
    group_by(county_code,district_code) %>%
    transmute(el.count = sum(english_learner_el),
              el.perc = sum(english_learner_el)/sum(total_enrollment),
              cds = glue('{county_code}{district_code}0000000') ) %>%
    ungroup() %>%
    select(el.count, el.perc , cds) %>%
    distinct() %>%
    bind_rows(el.charter)




el.count <- el.count %>%
    filter(cds == "27659610000000") %>%
    mutate(cds = "99999990000000") %>%
    bind_rows(el.count)



write_rds(el.count ,here("el.rds"))



# LTEL Counts -----


ltel.count.full <- tbl(con, "ELAS") %>%
 #   head(10) %>%
    filter(academic_year == max(academic_year),
           county_code == "27",
           #school_code == "0000000"
    ) %>%
    collect() 



ltel.charter <- ltel.count.full %>%
    filter(charter == "Y",
           gender == "ALL") %>%
    group_by(county_code,district_code, school_code) %>%
    transmute(ltel.sum = sum(ltel),
              cds = glue('{county_code}{district_code}{school_code}') ) %>%
    ungroup() %>%
    select(ltel.sum, cds) %>%
    unique() 


ltel.count <- ltel.count.full %>%
    filter(charter == "N/A",
           gender == "ALL") %>%
    group_by(county_code,district_code) %>%
    transmute(ltel.sum = sum(ltel),
              cds = glue('{county_code}{district_code}0000000') ) %>%
    ungroup() %>%
    select(ltel.sum, cds) %>%
    distinct() %>%
    bind_rows(ltel.charter)


# 
# ltel.count <- ltel.count %>%
#     filter(cds == "27659610000000") %>%
#     mutate(cds = "99999990000000") %>%
#     bind_rows(ltel.count)




write_rds(ltel.count ,here("ltel.rds"))



### End -----
