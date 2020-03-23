# dependencies
library(dplyr)
library(here)
library(readr)
library(sf)
library(tidycensus)

# read spatial data
zips <- st_read(here("data", "spatial", "zips.geojson"), crs = 4326, stringsAsFactors = FALSE) %>%
  rename(GEOID = GEOID10) %>%
  mutate(GEOID = as.numeric(GEOID)) %>%
  filter(GEOID %in% c(63010, 63045, 63155) == FALSE)

# download poverty 
poverty <- get_acs(table = "B17001", geography = "zcta", output = "wide") %>%
  filter(GEOID %in% zips$GEOID) %>%
  select(GEOID, B17001_015E, B17001_015M, B17001_016E, B17001_016M,
         B17001_029E, B17001_029M, B17001_030E, B17001_030M,
         B17001_044E, B17001_044M, B17001_045E, B17001_045M,
         B17001_058E, B17001_058M, B17001_059E, B17001_059M) %>%
  mutate(poverty_over65 = B17001_015E + B17001_016E + B17001_029E + B17001_030E) %>%
  mutate(no_poverty_over65 = B17001_044E + B17001_045E + B17001_058E + B17001_059E) %>%
  mutate(total = poverty_over65 + no_poverty_over65) %>%
  mutate(poverty_pct_over65 = poverty_over65/total*100) %>%
  select(GEOID, poverty_pct_over65)

write_csv(poverty, here("data", "demographics", "poverty2.csv"))
