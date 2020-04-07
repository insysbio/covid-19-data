[![Travis](https://travis-ci.org/insysbio/covid-19-data.svg?branch=master)](https://travis-ci.org/insysbio/covid-19-data)

# COVID-19 data

The goal of the project is to provide a simple and unified interface to COVID-19 latest datasets.

The homepage is located here: <https://insysbio.github.io/covid-19-data/>

## Table of contents

- [Usage](#Usage)
- [J.Hopkins' datasets](#J.Hopkins'-datasets)
- [Contributing](#Contributing)
- [Authors](#Authors)
- [License](#License)

## Usage

### Shell

Download all data in CSV format as local file using bash shell

```sh
curl 'https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json' --compressed > _combined.json
```

```sh
curl 'https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv' --compressed > _combined.csv
```

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

### Git

To clone the latest datasets to the directory *covid-19*

```sh
git clone -b docs --single-branch https://github.com/insysbio/covid-19-data.git covid-19
```

To update the previously cloned repository
```sh
cd covid-19
git fetch
git pull
```

## J.Hopkins' datasets

The most popular COVID-19 dataset from J.Hopkins team. The sources are located in [GitHub repository](https://github.com/CSSEGISandData/COVID-19) and updated daily.

The current interface performs some transformation and shares data from: 

- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv*
- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv*
- *csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv*

Files are combined and transformed to the following formats:

### CSV formatted
- <https://insysbio.github.io/covid-19-data/hopkins/csv/_combined.csv>
- https://insysbio.github.io/covid-19-data/hopkins/csv/territory-code.csv

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

### JSON formatted
- <https://insysbio.github.io/covid-19-data/hopkins/json/_combined.json>
- https://insysbio.github.io/covid-19-data/hopkins/json/territory-code.json

Available fields:

|||
--|--
**Province.State** | Territory name from the original dataset
**Country.Region** | Country name from the original dataset
**Lat, Long** | Latitude and longitude from the original dataset
**hasErrors** | If true there are errors in one of series data point
**timeseries** | Array of time series data, see below

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
```JSON
{
  "Afghanistan_": {
    "hasErrors": false,
    "Province.State": "",
    "Country.Region": "Afghanistan",
    "Lat": 33,
    "Long": 65,
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

Use [issues](https://github.com/insysbio/covid-19-data/issues) page to write about your ideas and found bugs.


## Authors

- [Evgeny Metelkin](https://github.com/metelkin) 
- [Aleksandr Stepanov](https://github.com/step-by-step)

## License

This repository is distributed under [MIT license](LICENSE).

&copy; InSysBio LLC, 2020
