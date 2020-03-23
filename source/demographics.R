# download demographic data

# dependencies
library(dplyr)
library(here)
library(readr)
library(sf)
library(tidycensus)
library(tigris)

# download and geoprocess zips
zip <- zctas(year = 2018, class = "sf") %>%
  st_transform(crs = 26915)

counties <- counties(state = 29, year = 2018, class = "sf") %>%
  filter(COUNTYFP %in% c("183", "189", "510")) %>%
  st_transform(crs = 26915)

intersect <- st_intersection(zip, counties)

zip_stl <- filter(zip, GEOID10 %in% intersect$GEOID10) %>%
  filter(GEOID10 >= 63000) %>% # exclude zips in IL
  filter(GEOID10 %in% c(63073, 63055, 63090) == FALSE) %>% # exclude sw zips
  filter(GEOID10 %in% c(63390, 63379, 63362, 63369) == FALSE) %>% # exclude nw zips
  select(GEOID10)

# store zip code .geojson
zip_stl %>%
  st_transform(crs = 4326) %>%
  st_write(., here("data", "spatial", "zips.geojson"), delete_dsn = TRUE)

# download poverty 
poverty <- get_acs(table = "B17001", geography = "zcta", output = "wide") %>%
  filter(GEOID %in% zip_stl$GEOID10) %>%
  select(GEOID, B17001_001E, B17001_001M, B17001_002E, B17001_002M) %>%
  rename(
    total = B17001_001E, 
    total_moe = B17001_001M, 
    poverty = B17001_002E, 
    poverty_moe = B17001_002M
  )

# store poverty data
write_csv(poverty, here("data", "demographics", "poverty.csv"))

# download age
age <- get_acs(table = "B01001", geography = "zcta", output = "wide") %>%
  filter(GEOID %in% zip_stl$GEOID10) %>%
  select(GEOID, B01001_001E, B01001_001M, 
         B01001_020E, B01001_021E, B01001_022E, B01001_023E, B01001_024E, B01001_025E,
         B01001_044E, B01001_045E, B01001_046E, B01001_047E, B01001_048E, B01001_049E) %>%
  mutate(over65 = B01001_020E + B01001_021E + B01001_022E + B01001_023E + B01001_024E + B01001_025E +
           B01001_044E + B01001_045E + B01001_046E + B01001_047E + B01001_048E + B01001_049E) %>%
  select(GEOID, B01001_001E, B01001_001M, over65) %>%
  rename(
    total = B01001_001E,
    total_moe = B01001_001M
  )

# store poverty data
write_csv(age, here("data", "demographics", "age.csv"))
