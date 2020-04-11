### read and transform covid-19 data
# https://github.com/CSSEGISandData/COVID-19

# library('tidyr')
# library('dplyr')
# library('jsonlite')
# library('ISOcodes')
# library('knitr')

# file location
# setwd('..')
data.repos <- './input/hopkins'
output.path <- file.path(getwd(),'./output')

report_file <- file.path(getwd(),'output', 'hopkins', 'dataset.md')
pages_url <- 'https://insysbio.github.io/covid-19-data/hopkins/'
report = '# J.Hopkins full dataset'

# country/territory
countries <- ISO_3166_1
country_vocabulary <- read.csv('./R/country_vocabulary.csv', stringsAsFactors = FALSE)
territories <- ISO_3166_2
territory_vocabulary <- read.csv('./R/territory_vocabulary.csv', stringsAsFactors = FALSE)

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

country_comparator <- function(country){
  byName <- countries$Alpha_2[match(country, countries$Name)]
  byOfficialName <- countries$Alpha_2[match(country, countries$Official_name)]
  byCommonName <- countries$Alpha_2[match(country, countries$Common_name)]
  byVocabulary <- country_vocabulary$Alpha_2[match(country, country_vocabulary$Name)]
  
  step1 <- ifelse(!is.na(byName), byName, byOfficialName)
  step2 <- ifelse(!is.na(step1), step1, byCommonName)
  step3 <- ifelse(!is.na(step2), step2, byVocabulary)
  
  err <- is.na(step3)
  if (any(err)) {
    uniqCountry <- paste0(unique(country[err]), collapse = ', ')
    warning(paste0('No id for: ', uniqCountry))
  }
  
  return(step3)
}

territory_comparator <- function(territory){
  byName <- territories$Code[match(territory, territories$Name)]
  byVocabulary <- territory_vocabulary$Code[match(territory, territory_vocabulary$Name)]
  
  step1 <- ifelse(!is.na(byName), byName, byVocabulary)
  
  err <- is.na(step1)
  if (any(err)) {
    uniqTerritory <- paste0(unique(territory[err]), collapse = ', ')
    warning(paste0('No id for: ', uniqTerritory))
  }
  
  return(step1)
}

combined_data <- bind_rows(data_confirmed0, data_recovered0, data_deaths0) %>% 
  pivot_longer(date_confirmed_columns) %>%
  pivot_wider(names_from = 'data_type', values_from = value) %>%
  mutate(date = as.Date(name, "X%m.%d.%y")) %>%
  group_by(Country.Region, Province.State) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(confirmed_new = confirmed - lag(confirmed, default = 0)) %>%
  mutate(recovered_new = recovered - lag(recovered, default = 0)) %>%
  mutate(deaths_new = deaths - lag(deaths, default = 0)) %>%
  mutate(hasErrors = is.na(confirmed_new) || (confirmed_new < 0) || is.na(recovered_new) || (recovered_new < 0) || is.na(deaths_new) || (deaths_new < 0)) %>% #  || 
  mutate(hasParent = Province.State != '') %>%
  select(-name) %>%
  ungroup()

combined_data$country_code <- country_comparator(combined_data$Country.Region)
combined_data$country_code3 <- countries$Alpha_3[match(combined_data$country_code, countries$Alpha_2)]
combined_data$territory_code <- territory_comparator(combined_data$Province.State)
combined_data$group = ifelse(combined_data$hasParent, combined_data$territory_code, combined_data$country_code)

# set latest data
latest_date <- max(combined_data$date)
report <- c(report, paste0('*The latest date in dataset: ', latest_date, '*'))

splitted_data <- combined_data %>%
  split(f = combined_data$group) %>%
  lapply(function(l){
    output = list(
      hasErrors = any(l$hasErrors),
      Province.State = l$Province.State[1],
      Country.Region = l$Country.Region[1],
      Lat = l$Lat[1],
      Long = l$Long[1],
      hasParent = l$hasParent[1],
      country_code = l$country_code[1],
      country_code3 = l$country_code3[1],
      group = l$group[1],
      timeseries = l %>% select(date, confirmed, recovered, deaths, confirmed_new, recovered_new, deaths_new, hasErrors)
    )
    if (!is.na(l$territory_code[1])) { output$territory_code = l$territory_code[1] }
    
    output
  })

### SAVE ALL TO FILE
dir.create(output.path, showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins'), showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins', 'csv'), showWarnings = FALSE)
dir.create(file.path(output.path, 'hopkins', 'json'), showWarnings = FALSE)

# CSV all
write.csv(combined_data, file.path(output.path, 'hopkins', 'csv', '_combined.csv'), row.names = FALSE, na="")
# CSV latest
combined_data_latest <- combined_data %>% subset(date == latest_date)
write.csv(combined_data_latest, file.path(output.path, 'hopkins', 'csv', '_latest.csv'), row.names = FALSE, na="")
# CSV territory
report_table_csv <- combined_data %>%
  group_by(group) %>%
  group_modify(function(.x,.y){
    fp <- file.path(output.path, 'hopkins', 'csv', paste0(.y$group, '.csv'))
    write.csv( .x, fp, row.names = FALSE, na="" )
    
    data.frame( # return
      Province.State = .x[1, 'Province.State'],
      Country.Region = .x[1, 'Country.Region'],
      CSV = paste0(pages_url, 'csv/', .y$group, '.csv'),
      JSON = paste0(pages_url, 'json/', .y$group, '.json'),
      country_code = .x$country_code[1],
      country_code3 = .x$country_code3[1],
      territory_code = ifelse(!is.na(.x$territory_code[1]), .x$territory_code[1], '')
    )
  })

# JSON all
jsonlite::write_json(splitted_data, file.path(output.path, 'hopkins', 'json', '_combined.json'), pretty = TRUE, auto_unbox = TRUE)
# JSON latest
splitted_data_latest <- splitted_data %>% lapply(function(l){
  time_series_latest_number <- l$timeseries$date == latest_date
  l$timeseries = l$timeseries[time_series_latest_number,]
  l
})
jsonlite::write_json(splitted_data_latest, file.path(output.path, 'hopkins', 'json', '_latest.json'), pretty = TRUE, auto_unbox = TRUE)
# JSON territory
tmp <- splitted_data %>%
  sapply(function(l){
    fp <- file.path(output.path, 'hopkins', 'json', paste0(l$group,'.json'))
    jsonlite::write_json(l, fp, pretty = TRUE, auto_unbox = TRUE)
  })

# save report to file
report <- c(report, '\n## Full dataset\n')
report <- c(report, paste0('- ', pages_url, 'csv/_combined.csv'))
report <- c(report, paste0('- ', pages_url, 'json/_combined.json'))
report <- c(report, '\n## Latest available date only\n')
report <- c(report, paste0('- ', pages_url, 'csv/_latest.csv'))
report <- c(report, paste0('- ', pages_url, 'json/_latest.json'))
report <- c(report, '\n## Splitted by territory\n')
report <- c(report, knitr::kable(report_table_csv))
writeLines(report, report_file)

### PLOT

#russia_data <- combined_data %>%
#  subset(subset = area == 'Russia_')

#plot(russia_data$date, russia_data$confirmed_new, log = 'y', xlab = 'Date', ylab = 'Confirmed new')
#points(russia_data$date, russia_data$recovered_new, col='green')
#points(russia_data$date, russia_data$deaths_new, col='red')
