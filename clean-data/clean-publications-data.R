
# Describe purpose --------------------------------------------------------

# This script pulls in data output from  the Publications smartsheet & 
#  transforms it to an analysis-ready structure.

# Get packages ------------------------------------------------------------

library(tidyverse)
library(janitor)
library(lubridate)
library(readxl)


# Import data -------------------------------------------------------------

pubs <- read_excel("raw-data/CTS Publications.xlsx") %>% 
  clean_names()

# Clean data --------------------------------------------------------------

# Keeping only pubs from study findings page then separating topic areas into 1 per row
pubs_include <- pubs %>% 
  filter(summarized_on_study_findings_page == "Yes") %>% 
  rename("topic_area"="topic_area_s") %>% 
  mutate(topic_area = str_replace(topic_area,";",",")) %>% 
  separate_rows(topic_area, sep = ",") %>% 
  mutate(topic_area = str_to_title(topic_area),
         topic_area = str_squish(topic_area),
         topic_area = str_trim(topic_area)) %>%
  mutate(topic_area = recode(topic_area, "Medication" = "Medications",
                             "Breast Cancers" = "Breast Cancer")) 
# select(row_id,topic_area,year_of_publication, title)


# Checking unique values of topic_area to ensure none had a comma in them or other 
# issues for parsing & adding any needed transformations to the code above.
pubs_include %>% 
  separate_rows(topic_area, sep = ",") %>% 
  select(topic_area) %>% 
  unique() %>% 
  arrange(topic_area) %>% 
  print(n=50)


# Output data -------------------------------------------------------------
pubs_include %>% 
  write_rds("clean-data/cts-publications-clean.rds")
