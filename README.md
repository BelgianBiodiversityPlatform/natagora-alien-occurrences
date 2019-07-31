# Observations.be - Non-native species occurrences in Wallonia, Belgium

## Rationale

This repository contains the functionality to standardize _Observations.be - Non-native species occurrences in Wallonia, Belgium_ to a [Darwin Core occurrence dataset](https://www.gbif.org/dataset-classes) that can be harvested by [GBIF](http://www.gbif.org). It was developed for the [TrIAS project](http://trias-project.be).

## Workflow

[observations.be](https://observations.be) database → monthly export → Darwin Core [SQL view](https://github.com/trias-project/natagora-alien-occurrences/blob/master/sql/observationsbe-extract.sql) → csv file

## Published dataset

* [Dataset on the IPT](https://ipt.biodiversity.be/resource?r=natagora-alien-occurrences)
* [Dataset on GBIF](https://doi.org/10.15468/p58ip1)

## Repo structure

The repository structure is based on [Cookiecutter Data Science](http://drivendata.github.io/cookiecutter-data-science/) and the [Checklist recipe](https://github.com/trias-project/checklist-recipe). 

```
├── README.md         : Description of this repository
├── LICENSE           : Repository license
├── references	      : Controlled vocabularies created for observations.be datasets
├── specifications    : Data specifications for the Darwin Core files
└── sql 						
    └── observationsbe-extract.sql : Darwin Core SQL view
```

## Contributors

[List of contributors](https://github.com/trias-project/natagora-alien-occurrences/contributors)

## License

[MIT License](https://github.com/trias-project/natagora-alien-occurrences/blob/master/LICENSE)
