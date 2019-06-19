/* Extraction from data out of observations.be

Steps 
1/ Extract data from observations.be restricted to Wallonia. Give commune and province name, and a grid square.
   We can (must! for efficiency reasons) restrict to a given segment (species group, date range, user...)
   ---> table trias.wselectie
   
2/ Translation of all values to GBIF values  
   ---> table trias.werktabel

3/ Real export  
  
*/


create index index_diergroep on obsbe.waarneming (ind_diergroep);  -- just in case...


/* STEP 1 */
drop table if exists trias.wselectie;
create table trias.wselectie
as
(
select 	w.id,
	case when v.id_species_type in ('Y') then 
			v.id_species 
		else
			v.id 
	end id_vogel, -- and not "w.id_vogel" in order not to take the synonym (see also v2.id later)
	w.datum, w.invoer_date, w.aantal, w.geslacht, w.geo_point, w.id_gebied, 
	regexp_replace(commune.naam,'\([^\)]*\)','') as gemeente, ''::text as deelgemeente, commune.prov_nr as prov_id, ifbl4_table.fid as ifbl4_id, ifbl4_table.code as ifbl4,
	w.id_user, w.ind_moderated, w.ind_diergroep, w.id_type_waarneming, w.toon_datum, w.id_kleed, w.id_activiteit,
	w.id_protocol, w.exact_meters, w.loc_methode, w.bijzonderheden, w.timestamp, w.exoot, w.id_daglijst,--w.id_biotoop, 
	w.details_locatie, w.kmvervaagd, w.id_type_waarneming typeID,w.toon_datum embargo_datum, w.zeker, id_type_determination_method
from	obsbe.waarneming w
		inner join obsbe.vogel v		ON (w.id_vogel = v.id)
		inner join obsbe.gebied commune ON ST_Contains(commune.geo_multi_poly, w.geo_point) AND commune.id_type_area=3 AND commune.active=1 
			AND commune.prov_nr > 20  -- only Wallonia (Natagora)
		inner join trias.ifbl4 ifbl4_table ON ST_Contains(ifbl4_table.geo_multi_poly, w.geo_point)
		-- BEGIN added to extract only non native (in general use that should be remove 
		inner join obsbe.species_local_info sli	on (v.id = sli.id_species)
		inner join obsbe.species_status ss		on (sli.id_species_status = ss.id)
		-- END
where 	
1=1												-- trick to allow all lines begin with "and"
and	w.aantal <> 0 
and w.zeker = 'J'  
and w.ind_moderated not in ('I','U','N')		-- do not consider "not approved", "in process of approvement", or "to be checked"
and	w.id_user not in (107991)				    -- remove data from user '%Florabank%'
and	w.id_vogel not in (198,1412)				-- Anas platyrhynchos not considered

-- { Parameters : we choose here a segment of the data (species group, date, user...)
-- and	date_part('year',w.datum)= '2017' -- between '2008' and '2019'			-- date range
	--and	w.datum < '2019-05-01'									--   "     "
--	and w.ind_diergroep=3											-- group choice (3 herpetology)
--	and w.id_user = 43487 										-- data from a given user

-- only Wallonia
and commune.prov_nr >= 22 
--

-- BEGIN added to extract only non native (in general use that should be remove 
and ss.id in (6,7,8,9)
-- END

--	limit 150    													-- limit for tests
-- } Parameters
)
;

/* STEP 2 */
drop table if exists trias.werktabel;
create 	table trias.werktabel
as
(
select	w.id, wg.id wg_id,
	(case when ( select distinct id_species from obsbe.species_names where id_species = v.id and id_language = 3 and pref_order in (0,999)) is null
	then v.naam_fr
	else ( select name from obsbe.species_names where id_species = v.id and id_language = 3 and pref_order in (0,999) limit 1 )
	end)
	naam_fr, v.naam_lat naam_lat, v.id speciesid, w.datum datum, w.invoer_date invoerdatum, 
	(case when 	(wg.aantal > 0)
	then
		wg.aantal 
	else
		w.aantal
	end) as aantal, 
	typeAct.id typeActID, 
	case 	when typeAct.id in (1,15,17,18,19,20,21,23,24,26,27,32,38,39,40,41,51,52,57,58,65,66,67,68,69,70,78,79,82,94,
				95,96,97,98,2002,2005,2010,2016,2019,2021,2023,2024,2026,2030,2032,2033,2035,2036,3007,3019,
				3020,3028,3029,3030,3036,3039,3040,3051,3052,3053,3064,3066,3067,3069,3073,3074,3075,3077,3092,
				3099,3100,3104,3106,3108,3114,3115,3117,3120,3121,3122,3135,3136,3137,3138,3140,3142,3143,3144,
				3146,3147,3148,3149,3150,3151,3154,3160,3161,3163,3164,3165,3166,3173,3174,3175,3177,3194,3195,
				3212,3217,3219,3237,3242,3247,3250,3254,3256,3257) then null
		when typeAct.id in (2,16,3180,3181,3184,3185,3187,3188,3189,3190,3191) then 'feeding'
		when typeAct.id in (7) then 'migrating northeast'
		when typeAct.id in (8) then 'migrating northwest'
		when typeAct.id in (9) then 'migrating southeast'
		when typeAct.id in (10) then 'migrating southwest'	
		when typeAct.id in (11) then 'migrating north'
		when typeAct.id in (12) then 'migrating south'
		when typeAct.id in (13) then 'migrating east'
		when typeAct.id in (14) then 'migrating west'
		when typeAct.id in (28,29,3240) then 'territorial behavior'	
		when typeAct.id in (33,84,3013,3023,3043,3110) then 'copulating' 
		when typeAct.id in (37) then 'spawning'		
		when typeAct.id in (90,93,3009,3017,3027,3037,3047) then 'attracted to light'
		when typeAct.id in (2022) then 'flushing'
		when typeAct.id in (2028) then 'hibernating'
		when typeAct.id in (3014,3024,3034) then 'laying egg'	
		when typeAct.id in (3057) then 'feeding'
		when typeAct.id in (3087) then 'moulting'
		when typeAct.id in (3093) then 'moving south'	
		when typeAct.id in (3094) then 'moving north'
		when typeAct.id in (3095) then 'moving west'
		when typeAct.id in (3096) then 'moving east'
		when typeAct.id in (3116) then 'transporting feed or faeces' 
		when typeAct.id in (3118) then 'courtship/mating' 
		when typeAct.id in (3119,3241) then 'nest building'
		when typeAct.id in (3124) then 'distraction display' 
		when typeAct.id in (3155,3193,3197,3218,3227,3236,3239,3255) then 'sun basking'
		when typeAct.id in (3056,3192) then 'social behavior'
		when typeAct.id in (3252) then 'aestivating'
		when typeAct.id in (3267) then 'emerging at dusk'
		when typeAct.id in (3059,3262,59,3061,61,3111,3112,3101,2034,3062,3060,3091,3070) then null
	else lower (typeAct.oms_en)
	end as act_behavior, 
	case 	when typeAct.id in (1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,23,25,26,28,29,30,31,32,33,37,41,51,52,
				57,64,65,67,69,70,71,72,77,78,79,80,81,82,84,90,93,94,95,96,97,98,2002,2005,2009,2010,2012,2016,
				2019,2021,2022,2023,2024,2026,2027,2028,2029,2032,2033,2035,2036,3001,3007,3009,3011,3012,3013,
				3014,3017,3019,3020,3021,3022,3023,3024,3027,3029,3030,3031,3032,3034,3036,3037,3039,3040,3043,
				3047,3051,3052,3053,3087,3092,3093,3094,3095,3096,3099,3100,3106,3108,3110,3114,3115,3116,3117,
				3118,3119,3120,3121,3122,3124,3135,3136,3138,3140,3144,3146,3147,3148,3149,3150,3151,3152,3154,
				3155,3157,3158,3161,3163,3165,3166,3175,3180,3181,3184,3185,3187,3188,3189,3190,3191,3192,3193,
				3194,3195,3196,3197,3198,3199,3212,3217,3218,3219,3220,3222,3227,3236,3237,3239,3240,3241,3242,
				3244,3246,3247,3249,3250,3252,3254,3255,3256,3257,3267) then 'casual observation'
		when typeAct.id in (24,68) then 'catch'
		when typeAct.id in (27,3143) then 'pellet examination'
		when typeAct.id in (66,3056) then 'observation with bat detector'
		when typeAct.id in (3057) then 'observation with bat detector'
		when typeAct.id in (3028,3104) then 'sugar bait'
--		when typeAct.id in (2024) then 'colony in trees'
--		when typeAct.id in (2026) then 'colony other'
		when typeAct.id in (3064,3177) then 'camera trap'
		when typeAct.id in (38) then 'catch by fishing rod'
		when typeAct.id in (39) then 'catch by net'
		when typeAct.id in (40) then 'catch by electrofishing'
		when typeAct.id in (58) then 'catch by sheer'
		when typeAct.id in (3066,3067,3069,3073,3074,3075,3077,3164) then 'specimen collected'
		when typeAct.id in (3137) then 'catch by fishermen'
		when typeAct.id in (3142) then 'snorkelling observation'
		when typeAct.id in (3173) then 'catch and removed'
		when typeAct.id in (3174) then 'sound trap'
		when typeAct.id in (3160) then 'observation with flashlight'
		when typeAct.id in (2030,3101,3059,3061,3262,3061,3111,3112,59,61,2034,3060,3062,3091,3070) then null
	else lower (typeAct.oms_en)
	end as act_samplingprotocol,
	case	when typeAct.id in (1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,19,20,24,25,27,28,29,30,31,32,33,37,38,39,40,41,51,58,
				64,66,68,69,71,72,77,80,81,82,84,90,93,94,95,96,97,98,2009,2010,2012,2022,2027,2028,2029,2030,
				3001,3009,3011,3012,3013,3014,3017,3021,3022,3023,3024,3027,3028,3031,3032,3034,3037,3043,3047,
				3056,3057,3064,3066,3067,3069,3073,3074,3075,3077,3087,3093,3094,3095,3096,3104,3108,3110,3116,
				3118,3119,3124,3135,3136,3137,3140,3142,3143,3151,3152,3155,3157,3158,3160,3163,3164,3166,3173,
				3174,3177,3180,3181,3184,3185,3187,3188,3189,3190,3191,3192,3193,3194,3196,3197,3198,3199,3212,
				3218,3219,3220,3222,3227,3236,3237,3239,3240,3241,3242,3244,3246,3249,3250,3252,3254,3255,3256,
				3257,3267) then null
		when typeAct.id in (17,18,21,23,52,65,70,2036,3007,3020,3030,3040,3161) then 'found dead'
		when typeAct.id in (26) then 'longterm stay'
		when typeAct.id in (57,2002,3106) then 'found as tracks'
		when typeAct.id in (2032,2033,2035,3165,2034) then 'washed ashore'
		when typeAct.id in (78) then 'at sleeping area'
		when typeAct.id in (79) then 'with color ring'
		when typeAct.id in (3053) then 'adult in territory'
		when typeAct.id in (3247) then 'accidentally introduced'
		when typeAct.id in (3092,3175) then 'in collection'
		when typeAct.id in (3099,3100,3101) then 'catch by cat'
		when typeAct.id in (2023) then 'near nest'
		when typeAct.id in (2024) then 'colony in trees'
		when typeAct.id in (2026) then 'colony'
		when typeAct.id in (3150) then 'found as excrements'
		when typeAct.id in (3217) then 'in web'
		when typeAct.id in (3036) then 'found as nest'
		when typeAct.id in (3051,3195) then 'occupied nest'
		when typeAct.id in (3114) then 'occupied nest with eggs'
		when typeAct.id in (3115) then 'occupied nest with young'
		when typeAct.id in (3122) then 'with brood patch'
		when typeAct.id in (3149) then 'windfarm victim'
		when typeAct.id in (3154) then 'window victim'
		when typeAct.id in (3195) then 'on drifting object'
		when typeAct.id in (3052) then 'pair in territory'
		when typeAct.id in (3148) then 'powerline victim'
		when typeAct.id in (3117) then 'probably nesting place'
		when typeAct.id in (3121) then 'recently hatched young'
		when typeAct.id in (3120) then 'recently used nest'
		when typeAct.id in (67,2005,2016,2019,3019,3029,3039) then 'road kill'
		when typeAct.id in (2021,3144,3146,3147) then 'injured'
		when typeAct.id in (3059,3262,59,61,3111,3112,3070) then null
		when typeAct.id in (3061) then 'accidentally introduced'
		when typeAct.id in (3062) then 'planted'
		when typeAct.id in (3060) then 'escaped'
		when typeAct.id in (3091) then 'sown'
	else lower (typeAct.oms_en)		
	end as act_OccRem,
	case when typeAct.id in (3111,3112) then 'microscopic examination'
	else null
	end as act_identificationremarks,
	case when typeAct.id in (3151) then 'pregnant'
	else null
	end as act_reproductiveCondition,
	

	TypeK.id TypeKid,   
	(case 	when typeK.id in (1,12,17,18,19,28,35,46,49,64,65,67,70,86,91,92,97,105,108,110,111,
				112,113,114,115,116,118,121,122,128,1004,1005,1006,1011,1025,1038,1039,
				1040,1050,1052,1053,1054,1064,1065,1067,1072,1090,1093,1094,1101,1102,1106,
				1107,1108,1115,1118,1121,1127,1137,1145,1146,1148,1149) then null 
		when typeK.id in (2,3,4,20,21,29,37,47,69,79,103,119,125,1014,1028,1029,1033,1042,
				1043,1056,1057,1059,1060,1061,1070,1081,1082,1120,1150) then 'adult' 
		when typeK.id in (23,101) then 'caterpillar' 
		when typeK.id in (24,56,66,106,124,1027,1013,1041,1055,1104,1110,1111,1030) then 'egg'
		when typeK.id in (1009) then 'chick' 
		when typeK.id in (1090) then null 
		when typeK.id in (29,37,47,103,119,125,1014,1028,1029,1042,1043,1056,1057,1059,1070,1150) then 'imago' 
		when typeK.id in (5,6,7,8,9,10,11,13,14,15,16,27,62,68,71,72,73,78,1002,1010,1119,1142) then 'juvenile' 
		when typeK.id in (52,74,120,123,1020,1034,1035,1048,1062,1063,1077) then 'larva'
		when typeK.id in (26,102,1089,1117,1139,1083,1084) then 'pupa' 
	 end) as kleed_lifeStage, 
	 case 	when typeK.id in (3,1004,1101) then 'summer plumage'
		when typeK.id in (4,1005,1102) then 'winter plumage'
		when typeK.id in (1148,1149) then 'found as cuticle'
		when typeK.id in (7) then '1st autumn plumage'
		when typeK.id in (8) then '1st winter plumage'
		when typeK.id in (9) then '1st summer plumage'
		when typeK.id in (10) then '2nd winter plumage'
		when typeK.id in (11) then '2nd summer plumage'
		when typeK.id in (12) then 'eclipse plumage'
		when typeK.id in (13) then '1st year plumage'
		when typeK.id in (14) then '1st cycle plumage'
		when typeK.id in (15) then '2nd cycle plumage'
		when typeK.id in (16) then '3rd cycle plumage'
		when typeK.id in (62) then '3rd winter plumage'
		when typeK.id in (65) then 'found as shell'
		when typeK.id in (72) then '4th cycle plumage'
		when typeK.id in (105) then 'found as case'
		when typeK.id in (108,1065) then 'found as substrate with miner damage'	
		when typeK.id in (1006,1072) then 'found as gall'
		when typeK.id in (86,91,97,128,1040,1054,1121) then 'deviant form'
		when typeK.id in (125,1029,1043,1057) then 'macropterous'
		when typeK.id in (1059,1150) then 'brachypterous'
		when typeK.id in (1107) then 'found as shell with remains'
		when typeK.id in (1108) then 'found as shield'
		when typeK.id in (1111,1130) then 'found as egg mass'
		when typeK.id in (1137) then 'metamorphosing'		
		when typeK.id in (1139) then 'found as cocoon'
		when typeK.id in (49,121,122,1038,1050,1052,1064,1094) then 'found as exuviae'
--		when typeK.id in (1090) then 'fossile'	
	else
		null
	end as kleed_OccRem,
	
	case 	when typeK.id in (57,1060,1032,126,1074,1046) then 'queen'
		when typeK.id in (127,58,1033,1061,1047,1075) then 'worker'	
		when typeK.id in (1081) then 'winged gyne'
		when typeK.id in (1082) then 'unwinged gyne'
		when typeK.id in (1165,1166,1113) then 'spore-bearing'
		when typeK.id in (1171,1161,1168,1153) then 'fruit-bearing'
		when typeK.id in (1170) then 'flowering'
		when typeK.id in (1170) then 'flowering'
		when typeK.id in (1145,1138) then 'reproductive' -- ??
		when typeK.id in (1103) then 'seedling'
		when typeK.id in (1163,1112) then 'vegetative'
	else 	null
	end	as kleed_reproductiveCondition,
	case 	when typeK.id in (110) then 'length < 2cm'
		when typeK.id in (111) then 'length 3-5cm'	
		when typeK.id in (112) then 'length 6-10cm'
		when typeK.id in (113) then 'length 11-15cm'	
		when typeK.id in (114) then 'length 16-25cm'	
		when typeK.id in (115) then 'length 26-40cm'
		when typeK.id in (116) then 'length >41cm'	
	else 	null
	end	as kleed_dynamicproperties,

	typeM.id TypeMid,
	case 	when typeM.id in (1,27,32,34,42,47,48,49,51,102,107,109,119,122,123,124,126,127,132,147,148,149,151,152,
				172,173,198,218,222,223,227,247,248,252,268,272,273,277,297,298,343,393,397,398,399,402,
				422,423,424,426,447,448,472,473,474,497,498,522,523,568,572,573,585,586,587,588,589,590,
				596,597,598,599,602,603,605,623,627,633,634,635,636,638,642,643,653,656,657,658,662,663,679,
				680,681,685,687,688,693,694,703,704,705,707,709,713,714,715,716,717,719,720,724,725,726,727,
				730,732,733,736,738,743,750,757,759,760,764,774,775) then null
		when typeM.id in (333,648) then 'grown' 		
		when typeM.id in (579,592,595,608,654,691,723,741,769,773) then 'found as tracks'
		when typeM.id in (591) then 'found as excrements'
		when typeM.id in (593) then 'found as feeding signs'
		when typeM.id in (594) then 'abandoned nest'
		when typeM.id in (600,639) then 'found as fossile'
		when typeM.id in (607,665) then null
		when typeM.id in (675) then 'grown and in collection'
		when typeM.id in (232,382,432,457,482,557) then 'in collection'
	end as met_OccRem,
	case 	when typeM.id in (1,47,122,147,172,218,222,232,247,268,272,297,333,343,382,393,397,422,432,447,457,472,482,497,
				522,557,568,572,579,591,592,593,594,595,600,607,608,638,639,648,654,665,675,691,723,741,769) then 'casual observation'
		when typeM.id in (27,102,127,152,227,252,277,402) then 'catch'
		when typeM.id in (32,107,132) then 'specimen collected'		
		when typeM.id in (34,109) then 'telemetry searching'
		when typeM.id in (42) then 'DNA barcoding'
		when typeM.id in (48,123,148,173,198,223,248,273,298,398,423,448,473,498,523,573) then 'seen'
		when typeM.id in (49,124,149,399,424,474) then 'heard'
		when typeM.id in (51,126,151,426) then 'seen and heard'	
		when typeM.id in (119) then 'observation with bat detector'
		when typeM.id in (585,599,688) then 'pellet examination'	
		when typeM.id in (586,590) then 'spotlight'
		when typeM.id in (587,596) then 'camera trap'
		when typeM.id in (588,597) then 'sound trap'
		when typeM.id in (589,633,642,653,693,713,730,743,757) then 'seen indoors'
		when typeM.id in (598,634,685,736) then 'pitfall trap'
		when typeM.id in (602,662) then 'catch by pod'
		when typeM.id in (603,635,657,663,681,705,725) then 'catch by net'
		when typeM.id in (623,680,715,733,760,774) then 'catch by hand and released'
		when typeM.id in (627,643,694,709,719) then 'light trap'
		when typeM.id in (636) then 'soil sample'
		when typeM.id in (656) then 'catch by electrofishing'
		when typeM.id in (658) then 'catch by pole'
		when typeM.id in (679,714,732,759,775) then 'catch by hand and collected'
		when typeM.id in (703) then 'catch by hand'
		when typeM.id in (704,726) then 'catch by trawl net'
		when typeM.id in (707,717) then 'colour trap'
		when typeM.id in (716) then 'malaise trap'
		when typeM.id in (724) then 'sugar bait'
		when typeM.id in (727) then 'catch by screen'
		when typeM.id in (773) then 'track bed'
		when typeM.id in (605,687,720,738,750,764) then 'unspecified trap'		
		when typeM.id in (607,665) then 'seen while diving'
	end as met_SamplingProtocol,
	case when typeM.id in (218,268,343,393,568) then 'microscopic examination'
	else null
	end as met_identificationremarks,

	(case when 	wg.geslacht is not null
		then
			wg.geslacht
		else
			w.geslacht 
	end) 
	as geslacht,
	cast(st_y(w.geo_point) as character varying) AS lat,				-- WGS84-coord.
	cast(st_x(w.geo_point) as character varying) AS lon,				-- WGS84-coord.
	w.gemeente, W.deelgemeente, W.prov_id, w.ifbl4_id, w.ifbl4, i4c.centroidlat, i4c.centroidlon,
	w.id_protocol protocol, w.exact_meters precisie, w.loc_methode, w.timestamp,
	regexp_replace(w.bijzonderheden, '[[:cntrl:],;]','_','g') as bijzonderheden,  -- remove characters that could damage csv file 
	w.details_locatie, w.kmvervaagd, w.id_type_waarneming typeID, typeWnm.oms typewaarneming, w.toon_datum embargo_datum, w.ind_moderated, st.status_oms_en status, ss.id ss_id,
	w.zeker, w.ind_diergroep, sg.oms_eng soortgroep, 
	sp_t.id soorttypeid, 
	(case when sp_t.id = 'Y' then 
		case when v.id in (19907,1595) then -- Anthropoides virgo and Deroceras panormitanum (synonyms)
			(select sp_t2.name_en 
			from obsbe.vogel v2
				left join obsbe.species_type sp_t2 	on (v2.id_species_type = sp_t2.id)
			where v.id_species = v2.id)
		else 
			'species'
		end
	else 
		case when sp_t.id = 'V' then 
			'variety'
		else
			sp_t.name_en
		end 
	end) as  soorttype,

	v.rights, w.exoot, w.id_daglijst,
	current_date aanleverdatum, u.id wnr_id, u.naam wnr, u.id_type_export toestemming_wnr, u.email email_wnr, u.push_embargo
from	trias.wselectie w
		inner join obsbe.vogel v			on (v.id = w.id_vogel)
		left join trias.ifbl4_centroid i4c		on (w.ifbl4_id = i4c.fid)
		inner join obsbe.users u			on (w.id_user = u.id)
		inner join trias.status st			on (w.ind_moderated = st.status_code)
		inner join obsbe.family f			on (v.id_taxo = f.id)
		inner join obsbe.type_diergroep sg		on (w.ind_diergroep = sg.ind)
		left outer join obsbe.waarneming_groep wg	on (w.id = wg.id_waarneming) 
		left OUTER JOIN obsbe.type_waarneming typeWnm ON (w.id_type_waarneming = typeWnm.id)  -- copied observations will not be taken
		left outer join obsbe.species_type sp_t 	on (v.id_species_type = sp_t.id)
		inner join obsbe.species_local_info sli	on (v.id = sli.id_species)
		inner join obsbe.species_status ss		on (sli.id_species_status = ss.id)
		left join obsbe.type_determination_method typeM	on (w.id_type_determination_method = typeM.id and typeM.active = 1)
	,
	obsbe.type_activiteit typeAct,
	obsbe.type_kleed typeK
where  ss.id in (6,7,8,9)						-- categories 2a, 2b, 2c and 2d (at Belgium level) 
and	(case when wg.id_kleed is not null
	then
		typeK.id=wg.id_kleed 
	else
		typeK.id=w.id_kleed 
	end) 
and	(case when wg.id_activiteit is not null
	then
		typeAct.id=wg.id_activiteit
	else
		typeAct.id=w.id_activiteit 
	end)
);


/* STEP 3 */
drop table trias.result;
create table trias.result as
(
select 	case when wt.wg_id is null then 'Natagora:Observations:'||wt.id
	else 'Natagora:Observations:'||wt.id||':'||wt.wg_id 
	end occurrenceID, 'Event'::varchar as type, --date(timestamp) modified, 
	'en'::char as language, 'http://creativecommons.org/publicdomain/zero/1.0/'::varchar as license,
	'Natagora'::varchar rightsHolder, 'https://www.natagora.be/donnees_naturalistes_usage'::varchar as accessRights, 
	'https://observations.be/waarneming/view/'::varchar||wt.id as references,
	''::varchar as datasetID,
	'Natagora'::varchar as institutionCode, 'Observations.be - Non-native animal occurrences in Wallonia, Belgium'::varchar as datasetName,
	case when TypeMid in (587,588,596,597) then 'MachineObservation'::varchar
	else 'HumanObservation'::varchar end basisOfRecord, 'see metadata'::varchar informationWithheld,
	case when embargo_datum > now() AND push_embargo = 1 
		then 'coordinates are generalized to a 4x4km IFBL grid'::varchar	
		else ''::varchar
	end as dataGeneralizations,
	aantal individualCount, 				 
	(case when geslacht ilike 'man' then 'male'
	     when geslacht ilike 'vrouw' then 'female'
	     when geslacht ilike 'paar%' then 'female & male'		
	     else ''::varchar
	  end) as sex,

	kleed_LifeStage as LifeStage, act_behavior as behaviour,
	concat_ws(' | ', act_occRem, kleed_occrem, met_occRem) as occurrenceRemarks,
	case 
	   when act_samplingprotocol = met_samplingprotocol then met_samplingprotocol
	   when act_samplingprotocol = 'casual observation' then met_samplingprotocol
	   when met_samplingprotocol = 'casual observation' then act_samplingprotocol
	   else concat_ws(' | ', act_samplingprotocol, met_samplingprotocol) 
	end as samplingProtocol,
	kleed_dynamicproperties as dynamicProperties,
	case when act_reproductiveCondition = kleed_reproductiveCondition then kleed_reproductiveCondition
	else concat_ws(' | ', kleed_reproductiveCondition, act_reproductiveCondition) 
	end as reproductiveCondition,
	case when act_identificationremarks = met_identificationremarks then act_identificationremarks
	else concat_ws(' | ', act_identificationremarks, met_identificationremarks) 
	end as identificationRemarks,
--	TypeKid, typeActid, TypeMid,					-- test
--	act_behavior, act_OccRem, act_samplingprotocol, -- test
--	kleed_LifeStage, kleed_OccRem, kleed_reproductiveCondition, kleed_dynamicproperties, -- test
--	met_occRem, met_samplingprotocol, met_identificationremarks, -- test
	to_char(datum, 'YYYY-MM-DD') eventDate,					
	 'Europe'::varchar continent, 'BE'::char countryCode,
	(case
		when prov_id = 19 then 'Région de Bruxelles Capitale'
		when prov_id = 22 then 'Liège'
		when prov_id = 23 then 'Hainaut'
		when prov_id = 24 then 'Namur'
		when prov_id = 25 then 'Brabant wallon'
		when prov_id = 26 then 'Luxembourg'
	end)
	as stateProvince, gemeente municipality,
	CASE kmvervaagd 
	WHEN 1 THEN ROUND(centroidlat::numeric,5)::text
	WHEN 0 THEN ROUND(lat::numeric,5)::text
	END as decimalLatitude,
	CASE kmvervaagd
	WHEN 1 THEN round(centroidlon::numeric,5)::text
	WHEN 0 THEN round(lon::numeric,5)::text 
	END as decimalLongitude, 
	'WGS84'::varchar as	geodeticDatum,
	CASE kmvervaagd
	WHEN 1 THEN 2828  -- sqrt(2)* 4km/2 = 
	WHEN 0 THEN precisie 
	END as coordinateUncertaintyInMeters,
	CASE kmvervaagd
	WHEN 1 THEN 'coordinates are centroid of used grid square' ::varchar
	ELSE ''
	END as georeferenceRemarks,
	status identificationVerificationStatus,  	
	'http://observations.be/soort/view/'::varchar|| speciesid taxonid,
	naam_lat scientificName,

	CASE ind_diergroep
	WHEN 10 THEN 'Plantae'::varchar
	WHEN 11 THEN 'Fungi'::varchar
	ELSE 'Animalia'::varchar 
	END as kingdom,
	soorttype taxonRank,
	rights scientificNameAuthorship,			
	naam_fr vernacularName,				
	CASE ind_diergroep
	WHEN 10 THEN 'ICN'::char -- plants
	WHEN 11 THEN 'ICN'::char -- fungi
	ELSE 'ICZN'::char 
	END as nomenclaturalCode
-- maybe to use in certain cases
--	,wnr, wnr_id
		
from	trias.werktabel wt

where 	case	when toestemming_wnr in (4) then true	-- "open data" users give all their data
	else
		case when toestemming_wnr in (2,3) then 
			case when embargo_datum >  now() AND push_embargo = 0 
				then false
			    else true 
			end
		end
	end
--limit 100

);
