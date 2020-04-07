### read and transform covid-19 data
# https://github.com/CSSEGISandData/COVID-19

# library('tidyr')
# library('dplyr')
# library('jsonlite')

data.repos <- './input/hopkins'
# setwd('..')

output.path <- file.path(getwd(),'./output')

# confirmed cases
filename_confirmed <- file.path(data.repos, 'csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv')
data_confirmed0 <- read.csv(filename_confirmed, stringsAsFactors = FALSE)
date_confirmed_columns <- names(data_confirmed0)[-c(1,2,3,4)]
data_confirmed0$data_type <- 'confirmed'

# recovered cases
filename_recovered <- file.path(data.repos, 'csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv')
data_recovered0 <- read.csv(filename_recovered, stringsAsFactors = FALSE)
date_recovered_columns <- names(data_recovered0)[-c(1,2,3,4)]
data_recovered0$data_type <- 'recovered'

# deaths cases
filename_deaths <- file.path(data.repos, 'csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv')
data_deaths0 <- read.csv(filename_deaths, stringsAsFactors = FALSE)
date_deaths_columns <- names(data_deaths0)[-c(1,2,3,4)]
data_deaths0$data_type <- 'deaths'

# comparing tables
diff_confirmed_recovered <- date_confirmed_columns != date_recovered_columns
if (any(diff_confirmed_recovered)) {
  stop('Inconsistency in columns between "confirmed" and "recovered"')
}
diff_confirmed_deaths <- date_confirmed_columns != date_deaths_columns
if (any(diff_confirmed_deaths)) {
  stop('Inconsistency in columns between "confirmed" and "deaths"')
}

# combining data

combined_data <- bind_rows(data_confirmed0, data_recovered0, data_deaths0) %>% 
  pivot_longer(date_confirmed_columns) %>%
  pivot_wider(names_from = 'data_type', values_from = value) %>%
  mutate(date = as.Date(name, "X%m.%d.%y")) %>%
  mutate(area = paste(Country.Region, Province.State, sep = '_')) %>%
  group_by(area) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(confirmed_new = confirmed - lag(confirmed, default = 0)) %>%
  mutate(recovered_new = recovered - lag(recovered, default = 0)) %>%
  mutate(deaths_new = deaths - lag(deaths, default = 0)) %>%
  mutate(hasErrors = is.na(confirmed_new) || (confirmed_new < 0) || is.na(recovered_new) || (recovered_new < 0) || is.na(deaths_new) || (deaths_new < 0)) %>% #  || 
  select(-name) %>%
  ungroup()

splitted_data <- combined_data %>%
  split(f = combined_data$area) %>%
  lapply(function(l){
    list(
      hasErrors = any(l$hasErrors),
      Province.State = l$Province.State[1],
      Country.Region = l$Country.Region[1],
      Lat = l$Lat[1],
      Long = l$Long[1],
      area = l$area[1],
      timeseries = l %>% select(date, confirmed, recovered, deaths, confirmed_new, recovered_new, deaths_new, hasErrors)
    )
  })

### SAVE ALL TO FILE
dir.create(output.path, showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins'), showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins', 'csv'), showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins', 'json'), showWarnings = FALSE)

# CSV all
write.csv(combined_data, file.path(output.path, 'hopkins', 'csv', '_combined.csv'), col.names = FALSE )
# JSON all
jsonlite::write_json(splitted_data, file.path(output.path, 'hopkins', 'json', '_combined.json'), pretty = TRUE, auto_unbox = TRUE)

# CSV country
combined_data$filename <- gsub('\\*', '_', combined_data$area)
res_csv <- combined_data %>%
  group_by(filename) %>%
  group_walk(
    ~ write.csv( .x, file.path(output.path, 'hopkins', 'csv', paste0(.y$filename,'.csv')), col.names = FALSE )
  )
# JSON country
res_json <- splitted_data %>%
  lapply(function (l) {
    filename <- gsub('\\*', '_', l$area)
    jsonlite::write_json(l, file.path(output.path, 'hopkins', 'json', paste0(filename,'.json')), pretty = TRUE, auto_unbox = TRUE)
  })

### PLOT

#russia_data <- combined_data %>%
#  subset(subset = area == 'Russia_')

#plot(russia_data$date, russia_data$confirmed_new, log = 'y', xlab = 'Date', ylab = 'Confirmed new')
#points(russia_data$date, russia_data$recovered_new, col='green')
#points(russia_data$date, russia_data$deaths_new, col='red')
