# Publication of non-native species occurrences from observations.be on GBIF

This repository contains the tasks/issues for publishing non-native species occurrences from the Natagora database (observations.be) to GBIF.
It has been developed in the context of the TrIAS project.

## Workflow
- Natagora: observations.be dump -> csv file (DaRWINCore)
- Natagora/INBO: csv file -> https://ipt.biodiversity.be

The first conversion is done using the SQL code file in present [sql](/trias-project/natagora-alien-occurrences/tree/master/sql) directory.

## Published dataset


Title  | DOI | Registration
--- | --- | ---
Observations.be - Non-native species occurrences in Wallonia, Belgium | https://doi.org/10.15468/p58ip1 | 2019-06-26

## Useful to know before running the SQL file

About 2% of the non-native species occurrences in the observations.be database are provided with the constraint not to make public their exact location. The centroid of the IFBL-4km square is then given for those sightings.

The IFBL layer can be found at https://github.com/BelgianBiodiversityPlatform/grids-belgium

Be careful only to import 4km squares (to table trias.ifbl4).
