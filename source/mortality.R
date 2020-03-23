# clean mortality data

# dependencies
library(dplyr)
library(here)
library(readr)

# cancer, all
cancer <- read_csv(here("data", "mortality", "raw", "cancer_all.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_cancer = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_cancer) %>%
  mutate(total_cancer = as.numeric(total_cancer))

# cancer, over65
cancer65 <- read_csv(here("data", "mortality", "raw", "cancer_over65.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_cancer65 = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_cancer65) %>%
  mutate(total_cancer65 = as.numeric(total_cancer65))

# copd, all
copd <- read_csv(here("data", "mortality", "raw", "copd_all.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_copd = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_copd) %>%
  mutate(total_copd = as.numeric(total_copd))

# copd, over65
copd65 <- read_csv(here("data", "mortality", "raw", "copd_over65.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_copd65 = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_copd65) %>%
  mutate(total_copd65 = as.numeric(total_copd65))

# diabetes, all
diabetes <- read_csv(here("data", "mortality", "raw", "diabetes_all.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_diabetes = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_diabetes) %>%
  mutate(total_diabetes = as.numeric(total_diabetes))

# diabetes, over65
diabetes65 <- read_csv(here("data", "mortality", "raw", "diabetes_over65.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_diabetes65 = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_diabetes65) %>%
  mutate(total_diabetes65 = as.numeric(total_diabetes65))

# diabetes, all
heart <- read_csv(here("data", "mortality", "raw", "heart_disease_all.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_heart = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_heart) %>%
  mutate(total_heart = as.numeric(total_heart))

# diabetes, over65
heart65 <- read_csv(here("data", "mortality", "raw", "heart_disease_over65.csv"), skip = 2) %>%
  rename(
    GEOID = `Year:`,
    total_heart65 = `Total for selection`
  ) %>%
  filter(GEOID %in% c("Statistics:", "Zip / ZCTA") == FALSE) %>%
  slice(1:(n()-6)) %>%
  select(GEOID, total_heart65) %>%
  mutate(total_heart65 = as.numeric(total_heart65))

# join all
left_join(cancer, copd, by = "GEOID") %>%
  left_join(., diabetes, by = "GEOID") %>%
  left_join(., heart, by = "GEOID") %>%
  filter(GEOID %in% c("63010", "63045", "63155") == FALSE) -> mortality_all

# join over 65
left_join(cancer65, copd65, by = "GEOID") %>%
  left_join(., diabetes65, by = "GEOID") %>%
  left_join(., heart65, by = "GEOID") %>%
  filter(GEOID %in% c("63010", "63045", "63155") == FALSE) -> mortality_over65

# clean-up
rm(cancer, cancer65, copd, copd65, diabetes, diabetes65, heart, heart65)

# read demographic data in 
age <- read_csv(here("data", "demographics", "age.csv")) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  filter(GEOID %in% c("63010", "63045", "63155") == FALSE)

poverty <- read_csv(here("data", "demographics", "poverty.csv")) %>%
  mutate(GEOID = as.character(GEOID)) %>%
  filter(GEOID %in% c("63010", "63045", "63155") == FALSE)

# join demographics
mortality_all <- left_join(poverty, mortality_all, by = "GEOID")
mortality_over65 <- left_join(age, mortality_over65, by = "GEOID")

# clean-up
rm(age, poverty)

# calculate totals and rates
mortality_all %>%
  rowwise() %>%
  mutate(mortality = sum(total_cancer, total_copd, total_diabetes, total_heart, na.rm=TRUE)) %>%
  ungroup() %>%
  mutate(mortality_rate = mortality/total*1000) %>%
  mutate(poverty_rate = poverty/total*1000) %>%
  select(GEOID, total, total_moe, poverty, poverty_moe, poverty_rate, everything()) -> mortality_all

mortality_over65 %>%
  rowwise() %>%
  mutate(mortality = sum(total_cancer65, total_copd65, total_diabetes65, total_heart65, na.rm=TRUE)) %>%
  ungroup() %>%
  mutate(over65_rate = over65/total*1000) %>%
  mutate(mortality_rate = mortality/over65*1000) %>%
  select(GEOID, total, total_moe, over65, over65_rate, everything()) -> mortality_over65

# write data
write_csv(mortality_all, here("data", "mortality", "mortality_all.csv"))
write_csv(mortality_over65, here("data", "mortality", "mortality_over65.csv"))
