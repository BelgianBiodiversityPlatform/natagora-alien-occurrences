# Observations.be - Species occurrence datasets published by Natagora

## Rationale

This repository contains the functionality to standardize datasets of [observations.be](https://observations.be) to [Darwin Core Occurrence](https://www.gbif.org/dataset-classes) datasets that can be harvested by [GBIF](http://www.gbif.org). It was originally developed for the [TrIAS project](http://trias-project.be).

## Workflow

[observations.be](https://observations.be) database → Darwin Core SQL view → Direct connection with the IPT or CSV upload

## Datasets

Title (and GitHub directory) | IPT | GBIF
--- | --- | ---
[Observations.be - Non-native species occurrences in Wallonia, Belgium](datasets/natagora-alien-occurrences) | [natagora-alien-occurrences](https://ipt.biodiversity.be/resource?r=natagora-alien-occurrences) | <https://doi.org/10.15468/p58ip1>
[Observations.be - Orthoptera occurrences in Wallonia, Belgium](datasets/natagora-orthoptera-occurrences) | [natagora-orthoptera-occurrences](https://ipt.biodiversity.be/resource.do?r=natagora-orthoptera-occurrences) | <https://doi.org/10.15468/r763pb>

## Repo structure

The structure for each dataset in [datasets](datasets) is based on [Cookiecutter Data Science](http://drivendata.github.io/cookiecutter-data-science/) and the [Checklist recipe](https://github.com/trias-project/checklist-recipe). Files and directories indicated with `GENERATED` should not be edited manually.

```
├── sql                      : Darwin Core SQL queries
│
└── specs                    : Whip specifications for validation
```

[references](references) contains controlled vocabularies for:

- [behavior](references/behavior.csv)
- [lifeStage](references/lifeStage.csv)
- [occurrenceRemarks](references/occurrenceRemarks.csv)
- [reproductiveCondition](references/reproductiveCondition.csv)
- [samplingProtocol](references/samplingProtocol.csv)

These are shared with the [waarnemingen.be datasets](https://www.gbif.org/dataset/search?q=waarnemingen.be).

## Contributors

[List of contributors](https://github.com/trias-project/natagora-occurrences/contributors)

## License

[MIT License](https://github.com/trias-project/natagora-occurrences/blob/master/LICENSE)
