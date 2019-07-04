# Observations.be - Non-native species occurrences in Wallonia, Belgium

## Rationale

This repository contains the functionality to standardize the [Observations.be - Non-native species occurrences in Wallonia, Belgium](https://observations.be/user/inquiry/170271) to a [Darwin Core checklist](https://www.gbif.org/dataset-classes) that can be harvested by [GBIF](http://www.gbif.org). It was developed for the [TrIAS project](http://trias-project.be).

## Workflow

observations.be database → monthly dump → Darwin Core [mapping script](https://github.com/trias-project/natagora-alien-occurrences/blob/master/sql/observationsbe-extract.sql) → Darwin Core mapping SQL View -> 1 	Darwin Core file (csv)

## Published dataset

* [Dataset on the IPT](https://ipt.biodiversity.be/resource?r=natagora-alien-occurrences)
* [Dataset on GBIF](https://www.gbif.org/dataset/629befd5-fb45-4365-95c4-d07e72479b37)

## Repo structure

The repository structure is based on [Cookiecutter Data Science](http://drivendata.github.io/cookiecutter-data-science/) and the [Checklist recipe](https://github.com/trias-project/checklist-recipe). 

```
├── README.md              			: Description of this repository
├── LICENSE                			: Repository license
├── references			   			: Controlled vocabularies created for observations.be datasets
├── specification		   
	└── dwc_occurrence.yaml			: whip specification for the data
└── sql 						
    └── observationsbe-extract.sql 	: Darwin Core mapping script

## Contributors

[List of contributors](https://github.com/trias-project/alien-mollusca-checklist/contributors)

## License
