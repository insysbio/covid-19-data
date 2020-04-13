[![Travis](https://travis-ci.org/insysbio/covid-19-data.svg?branch=master)](https://travis-ci.org/insysbio/covid-19-data)
[![GitHub license](https://img.shields.io/github/license/insysbio/covid-19-data.svg)](https://github.com/insysbio/covid-19-data/blob/master/LICENSE)

# COVID-19 data

The goal of the project is to provide a simple and unified HTTP interface to COVID-19 latest datasets. The shared dataset updates daily to have fresh data.

Currenty the project includes only the data from J.Hopkins but may be extended in future. How this works: (1) download data from repos, (2) combine data tables and tidy them, (3) save in [different formats](./hopkins/dataset) on github pages.

## Table of contents

- [Motivation](#Motivation)
- [Usage](#Usage)
- [J.Hopkins' datasets](#jhopkins39-datasets)
- [Contributing](#Contributing)
- [Authors](#Authors)
- [License](#License)

## Motivation

COVID-19 data analysis and visualization has a great impact in 2020 all over the world. We developed this repository to support data data analysis, model development and online tools by simplifying the access to the data.

## Usage

### R

downloading JSON
```r
# install.packages('httr')

response <- httr::GET('https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json')
response_json <- httr::content(response, as = 'parsed', type = 'application/json')
```

downloading CSV
```r
# install.packages('httr')

response <- httr::GET('https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv')
response_csv <- httr::content(response, as = 'parsed', type = 'text/csv')
```

### Julia

downloading JSON
```julia
# ] add HTTP JSON
using HTTP, JSON

response = HTTP.get("https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json")
response_json = JSON.parse(String(response.body))
```

downloading CSV
```julia
# ] add HTTP CSV
using HTTP, CSV

response = HTTP.get("https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv")
response_csv = CSV.read(response.body)
```

### Shell

Download all data in CSV format as local file using bash shell

```bash
curl 'https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json' --compressed > _combined.json
```

```bash
curl 'https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv' --compressed > _combined.csv
```

### Git

To clone the latest datasets to the directory *covid-19*

```bash
git clone -b docs --single-branch https://github.com/insysbio/covid-19-data.git covid-19
```

To update the previously cloned repository
```bash
cd covid-19
git fetch
git pull
```

## J.Hopkins' datasets

This is the most popular COVID-19 dataset supported the Johns Hopkins University Applied Physics Lab (JHU APL). The sources are located in [GitHub repository](https://github.com/CSSEGISandData/COVID-19) and updated daily.

The current interface performs some transformation and shares data from: 

- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv*
- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv*
- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv*

Files are combined and transformed to the following formats:

### CSV formatted
- <https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv>
- `https://insysbio.github.io/covid-19-data/hopkins/csv/<territory-code>.csv`

*See also [full dataset](./hopkins/dataset) description* 

Available fields:

|||
--|--
**Province.State** | Territory name from the original dataset
**Country.Region** | Country name from the original dataset
**Lat, Long** | Latitude and longitude from the original dataset
**confirmed** | Confirmed cumulative cases
**recovered** | Recovered cumulative cases
**deaths** | Deaths cumulative cases
**date** | Date in format YYYY-mm-dd
**confirmed_new** | Confirmed cases for the date (calcuated as `today - yesterday`)
**recovered_new** | Recovered cases for the date
**deaths_new** | Deaths cases for the date
**hasErrors** | If true there are missing data or inconsistency between yesterday and today
**country_code** | Two-letter country code based on ISO:3166 standard*
**country_code3** | Three-letter country code based on ISO:3166 standard*
**territory_code** | Territory code or two-leter country code based on ISO:3166 standard*
**hasParent** | If TRUE the data refer to the region of some "parent" country
**group** | unique id of group: if hasParent==TRUE, it is "territory_code", and "country_code" otherwise

\* *to read more about country code standard: <https://www.iso.org/iso-3166-country-codes.html>*

### JSON formatted
- <https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json>
- `https://insysbio.github.io/covid-19-data/hopkins/json/<territory-code>.json`

*See also [full dataset](./hopkins/dataset) description* 

Available fields:

|||
--|--
**Province.State** | Territory name from the original dataset
**Country.Region** | Country name from the original dataset
**Lat, Long** | Latitude and longitude from the original dataset
**hasErrors** | If true there are errors in one of series data point
**country_code** | Two-letter country code based on ISO:3166 standard*
**country_code3** | Three-letter country code based on ISO:3166 standard*
**territory_code** | Territory code or two-leter country code based on ISO:3166 standard*
**hasParent** | If TRUE the data refer to the region of some "parent" country
**group** | unique id of group: if hasParent==TRUE, it is "territory_code", and "country_code" otherwise
**timeseries** | Array of time series data, see below

\* *to read more about country code standard: <https://www.iso.org/iso-3166-country-codes.html>*

Time series fields:

|||
--|--
**date** | Date in format YYYY-mm-dd
**confirmed** | Confirmed cumulative cases
**recovered** | Recovered cumulative cases
**deaths** | Deaths cumulative cases
**confirmed_new** | Confirmed cases for the date (calcuated as `today - yesterday`)
**recovered_new** | Recovered cases for the date
**deaths_new** | Deaths cases for the date
**hasErrors** | If true there are missig data or inconsistency between yesterday and today

**Example**
```json
{
  "AD": {
    "hasErrors": false,
    "Province.State": "",
    "Country.Region": "Andorra",
    "Lat": 42.5063,
    "Long": 1.5218,
    "isTerritory": false,
    "country_code": "AD",
    "group": "AD",
    "timeseries": [
      {
        "date": "2020-01-22",
        "confirmed": 0,
        "recovered": 0,
        "deaths": 0,
        "confirmed_new": 0,
        "recovered_new": 0,
        "deaths_new": 0,
        "hasErrors": false
      },
      {
        "date": "2020-01-23",
        "confirmed": 0,
        "recovered": 0,
        "deaths": 0,
        "confirmed_new": 0,
        "recovered_new": 0,
        "deaths_new": 0,
        "hasErrors": false
      },
      ...
    ]
  },
  ...
}
```

### Untransformed files

- https://insysbio.github.io/covid-19-data/hopkins/source/time_series_covid19_confirmed_global.csv
- https://insysbio.github.io/covid-19-data/hopkins/source/time_series_covid19_recovered_global.csv
- https://insysbio.github.io/covid-19-data/hopkins/source/time_series_covid19_deaths_global.csv
- https://insysbio.github.io/covid-19-data/hopkins/source/time_series_covid19_confirmed_US.csv
- https://insysbio.github.io/covid-19-data/hopkins/source/time_series_covid19_deaths_US.csv

## Contributing

- Use [issues](https://github.com/insysbio/covid-19-data/issues) page to write about your ideas and found bugs.
- Let us know if you use the data for your study or application

## Authors

- [Evgeny Metelkin](https://github.com/metelkin) 
- [Aleksandr Stepanov](https://github.com/step-by-step)
- [Ivan Borisov](https://github.com/ivborissov) 

## License

This repository is distributed under [MIT license](LICENSE).

&copy; InSysBio LLC, 2020
