
### Load libraries -----

library(tidyverse)
library(here)


### Import data -------


metrics <- tibble("priority_area" = c(rep("Conditions for Learning",5),rep("Pupil Outcomes",7), rep("Engagement",10) ) ,
                  "priorities" = c(rep("Basic",3),"Standards","Access", rep("Pupil Achievement", 6), "Other Pupil Outcomes", rep("Parent Involvement",2), rep("Pupil Engagement", 5), rep("School Climate",3) ),
                  "metrics" = c("TeachersCred","Materials","GoodRepair","Standards","BroadCourse","CAASP","A_G","ELPI","reclass","AP","EAP","outcomes_other", "ParentInput","UnduplicatedParentPart","Attendance","ChronicAbs","MSdropout","HSdropout","HSgrad","susp","exp","local_other"),
                  "source" = c(rep("dash_local",5),rep("dash",3),"dq", "dash", "dq", "local",rep("dash_local",2), "local", "dash", rep("dq",2), rep("dash",2), "dq", "dash_local"   )
)


dashboard_all <- read_rds(here("data","Dashboard_all.rds"))

dashboard_mry <- dashboard_all %>% 
    filter(str_detect("Monterey",countyname),
           year == "2019")
    

### Manipulate -----

elpi <- dashboard_mry %>%
    filter(ind == "elpi") %>%
    select(cds:countyname,currstatus)

A_G <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL")  %>%
    select(cds:countyname,currstatus,currdenom ,curr_prep_agplus, curr_prep_cteplus,  curr_aprep_ag, curr_aprep_cte) %>%
    mutate(ag_cte = curr_prep_agplus + curr_prep_cteplus + curr_aprep_ag + curr_aprep_cte,
           ag_cte_perc = ag_cte/currdenom)
# Note, this is the best possible calculation, but will be slightly inflated for students that completed A-G and also complete a CTE pathway. 
# It is not possible to get the exact figure with the aggregate data available


AP <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL")  %>%
    select(cds:countyname,currstatus,currdenom , curr_prep_apexam ) %>%
    mutate(ap = curr_prep_apexam/currdenom)
# Note this is percentage of cohort that passed TWO AP exams. PErcentage that passed a single one is not available on Dashboard

chronic <- dashboard_mry %>%
    filter(ind == "cci",
           studentgroup == "ALL") %>%
    select(cds:countyname, chronic = currstatus) 

grad <- dashboard_mry %>%
    filter(ind == "grad",
           studentgroup == "ALL") %>%
    select(cds:countyname, grad = currstatus) 


### End -----
