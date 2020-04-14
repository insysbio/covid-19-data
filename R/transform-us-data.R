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
output.path <- file.path(getwd(), 'output', 'us')

report_file <- file.path(output.path, 'dataset.md')
pages_url <- 'https://insysbio.github.io/covid-19-data/us/'
report = '# US dataset'

# country/territory
territories <- ISO_3166_2
territory_vocabulary <- read.csv('./R/territory_vocabulary.csv', stringsAsFactors = FALSE)

# UNIQUE KEY
key <- 'Combined_Key'

# confirmed cases
filename_confirmed <- file.path(data.repos, 'csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv')
data_confirmed0 <- read.csv(filename_confirmed, stringsAsFactors = FALSE)
date_confirmed_columns <- names(data_confirmed0)[-(1:11)]
data_confirmed0$data_type <- 'confirmed'
# check dupicates
date_confirmed_dupl <- duplicated(data_confirmed0[key])
if(any(date_confirmed_dupl)){
  stop('duplicated keys in confirmed')
}

# deaths cases
filename_deaths <- file.path(data.repos, 'csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv')
data_deaths0 <- read.csv(filename_deaths, stringsAsFactors = FALSE) %>% select(-Population)
date_deaths_columns <- names(data_deaths0)[-(1:11)]
data_deaths0$data_type <- 'deaths'
date_deaths_dupl <- duplicated(data_deaths0[key])
if(any(date_confirmed_dupl)){
  stop('duplicated keys in deaths')
}

# comparing tables
diff_confirmed_deaths <- date_confirmed_columns != date_deaths_columns
if (any(diff_confirmed_deaths)) {
  stop('Inconsistency in columns between "confirmed" and "deaths"')
}

# combining data
territories <- subset(territories, subset = Code!='BG-12') # remove wrong montana
territories <- subset(territories, subset = Code!='LR-MY') # remove wrong maryland
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

combined_data <- bind_rows(data_confirmed0, data_deaths0) %>% 
  pivot_longer(date_confirmed_columns) %>%
  pivot_wider(id_cols = c(Combined_Key, name, Admin2, Province_State, Country_Region), names_from = data_type, values_from = value) %>%
  rename(Province.State = 'Province_State', Country.Region = 'Country_Region') %>%
  mutate(date = as.Date(name, "X%m.%d.%y")) %>%
  group_by(Combined_Key) %>%
  arrange(date, .by_group = TRUE) %>%
  mutate(confirmed_new = confirmed - lag(confirmed, default = 0)) %>%
  mutate(deaths_new = deaths - lag(deaths, default = 0)) %>%
  mutate(hasErrors = is.na(confirmed_new) || (confirmed_new < 0) || is.na(deaths_new) || (deaths_new < 0)) %>%
  mutate(hasParent = TRUE) %>%
  select(-name) %>%
  ungroup()

combined_data$country_code <- 'US'
combined_data$country_code3 <- 'USA'
combined_data$territory_code <- territory_comparator(combined_data$Province.State)
no_blank_Admin2 <- gsub(' ', '_', combined_data$Admin2)
combined_data$group = paste(combined_data$territory_code, no_blank_Admin2, sep = '-')

# set latest data
report <- c(report, paste0('*The build date: ', build_date, '.*'))
latest_date <- max(combined_data$date)
report <- c(report, paste0('\n*The latest date in dataset: ', latest_date, '.*'))

splitted_data <- combined_data %>%
  split(f = combined_data$group) %>%
  lapply(function(l){
    output = list(
      hasErrors = any(l$hasErrors),
      Admin2 = l$Admin2[1],
      Country.Region = l$Country.Region[1],
      Province.State = l$Province.State[1],
      Lat = l$Lat[1],
      Long = l$Long[1],
      hasParent = l$hasParent[1],
      country_code = l$country_code[1],
      country_code3 = l$country_code3[1],
      group = l$group[1],
      timeseries = l %>% select(date, confirmed, deaths, confirmed_new, deaths_new, hasErrors)
    )
    if (!is.na(l$territory_code[1])) { output$territory_code = l$territory_code[1] }
    
    output
  })

### SAVE ALL TO FILE
dir.create(output.path, showWarnings = FALSE)
dir.create(file.path(output.path, 'csv'), showWarnings = FALSE)
dir.create(file.path(output.path, 'json'), showWarnings = FALSE)

# CSV all
write.csv(combined_data, file.path(output.path, 'csv', '_combined.csv'), row.names = FALSE, na="")
# CSV latest
combined_data_latest <- combined_data %>% subset(date == latest_date)
write.csv(combined_data_latest, file.path(output.path, 'csv', '_latest.csv'), row.names = FALSE, na="")
# CSV territory
report_table_csv <- combined_data %>%
  group_by(group) %>%
  group_modify(function(.x,.y){
    fp <- file.path(output.path, 'csv', paste0(.y$group, '.csv'))
    write.csv( .x, fp, row.names = FALSE, na="" )
    
    data.frame( # return
      Admin2 = .x[1, 'Admin2'],
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
jsonlite::write_json(splitted_data, file.path(output.path, 'json', '_combined.json'), pretty = TRUE, auto_unbox = TRUE)
# JSON latest
splitted_data_latest <- splitted_data %>% lapply(function(l){
  time_series_latest_number <- l$timeseries$date == latest_date
  l$timeseries = l$timeseries[time_series_latest_number,]
  l
})
jsonlite::write_json(splitted_data_latest, file.path(output.path, 'json', '_latest.json'), pretty = TRUE, auto_unbox = TRUE)
# JSON territory
tmp <- splitted_data %>%
  sapply(function(l){
    fp <- file.path(output.path, 'json', paste0(l$group,'.json'))
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
