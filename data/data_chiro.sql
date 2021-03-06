
INSERT INTO gn_commons.bib_tables_location(table_desc, schema_name, table_name, pk_field, uuid_field_name)
VALUES
('Liste des taxons observés durant une visite chiroptère', 'monitoring_chiro', 't_visite_contact_taxons', 'id_contact_taxon', 'uuid_chiro_visite_contact_taxon'),
('Liste des indices ayant conduit à l''identification d''un taxon lors d''une visite', 'monitoring_chiro', 'cor_contact_taxons_nomenclature_indices',
'uuid_chiro_visite_contact_indices', 'uuid_chiro_visite_contact_indices'
),
('Conditions de la visite d''un gite de chiroptère', 'monitoring_chiro', 't_visite_conditions', 'id_base_visit', 'uuid_chiro_visite_conditions'),
('Information complémentaire de description des sites à chiroptère', 'monitoring_chiro', 't_site_infos', 'id_base_site', 'uuid_chiro_site_infos'),
('Menaces relevés sur un site à chiroptère', 'monitoring_chiro', 'cor_site_infos_nomenclature_menaces', 'uuid_chiro_site_menaces', 'uuid_chiro_site_menaces'),
('Aménagements relevés sur un site à chiroptère', 'monitoring_chiro', 'cor_site_infos_nomenclature_amenagements', 'uuid_chiro_site_amenagements', 'uuid_chiro_site_amenagements'),
('Données de biométrie des chiroptères mesurés lors d''une capture', 'monitoring_chiro', 't_contact_taxon_biometries', 'id_biometrie', 'uuid_chiro_biometrie'),
('Données dénombrement des taxons observés durant une visite chiroptère', 'monitoring_chiro', 'cor_counting_contact', 'id_counting_contact', 'unique_id_sinp') ;

-- ###########################
-- Nomenclatures
-- ###########################


-- Nouveaux types

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (id_type, mnemonique, label_default, definition_default, label_fr, definition_fr, source, statut, meta_create_date, meta_update_date) VALUES
((SELECT max(id_type)+1 FROM ref_nomenclatures.bib_nomenclatures_types), 'CHI_FREQUENTATION', 'Fréquentation', 'Indique le niveau de fréquentation d''un site', 'Fréquentation', 'Indique le niveau de fréquentation d''un site', 'monitoring_chiro', 'Validation en cours',  '2018-01-01 00:00:00', '2018-01-01 00:00:00');

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (id_type, mnemonique, label_default, definition_default, label_fr, definition_fr, source, statut, meta_create_date, meta_update_date) VALUES
((SELECT max(id_type)+1 FROM ref_nomenclatures.bib_nomenclatures_types),'CHI_AMENAGEMENT', 'Aménagement', 'Type d''aménagement réalisables sur un site', 'Aménagement', 'Type d''aménagement réalisables sur un site', 'monitoring_chiro', 'Validation en cours',  '2018-01-01 00:00:00', '2018-01-01 00:00:00');

INSERT INTO ref_nomenclatures.bib_nomenclatures_types (id_type, mnemonique, label_default, definition_default, label_fr, definition_fr, source, statut, meta_create_date, meta_update_date) VALUES
((SELECT max(id_type)+1 FROM ref_nomenclatures.bib_nomenclatures_types),'CHI_MENACES', 'Menaces', 'Menaces qui peuvent être éxercer sur un site', 'Menaces', 'Menaces qui peuvent être éxercer sur un site', 'monitoring_chiro', 'Validation en cours',  '2018-01-01 00:00:00', '2018-01-01 00:00:00');

-- CREATION NOMENCLATURES
INSERT INTO ref_nomenclatures.t_nomenclatures(
	id_type, cd_nomenclature,
	mnemonique, label_default, label_fr,
	source, statut, id_broader, hierarchy, active
)
VALUES
(ref_nomenclatures.get_id_nomenclature_type('METH_OBS'),'CADAVRE','Cadavre','Cadavre','Cadavre','monitoring_chiro','Validation en cours', 0,'014.003.026',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('STATUT_BIO'),'RC','Reproduction certaine','Reproduction certaine','Reproduction certaine','monitoring_chiro','Validation en cours',0,'013.003.002',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('STATUT_BIO'),'RP','Reproduction probable','Reproduction probable','Reproduction probable','monitoring_chiro','Validation en cours',0,'013.003.001',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_AMENAGEMENT'),'FC','Fermeture avec chiropière','Fermeture avec chiropière','Fermeture avec chiropière','monitoring_chiro','Validation en cours', 0,'013.002',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_AMENAGEMENT'),'NC','Nichoir','Nichoir','Nichoir','monitoring_chiro','Validation en cours', 0,'013.001',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_MENACES'),'modification','Modifications du milieu (coupes de bois, défrichement, mise en culture)','Modifications du milieu (coupes de bois, défrichement, mise en culture)','Modifications du milieu (coupes de bois, défrichement, mise en culture)','monitoring_chiro','Validation en cours', 0,'011.005',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_MENACES'),'traitement','Traitements chimiques proches','Traitements chimiques proches','Traitements chimiques proches','monitoring_chiro','Validation en cours', 0,'011.004',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_MENACES'),'dégradation','Dégradation (Réfection des sites accueillant des individus)','Dégradation (Réfection des sites accueillant des individus)','Dégradation (Réfection des sites accueillant des individus)','monitoring_chiro','Validation en cours', 0,'011.003',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_MENACES'),'destruction','Destruction/Dérangement direct (visite des sites)','Destruction/Dérangement direct (visite des sites)','Destruction/Dérangement direct (visite des sites)','monitoring_chiro','Validation en cours', 0,'011.002',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_FREQUENTATION'),'forte','Importante (accès facile, proximité GR, bâti remarquable souvent visité)','Importante (accès facile, proximité GR, bâti remarquable souvent visité)','Importante (accès facile, proximité GR, bâti remarquable souvent visité)','monitoring_chiro','Validation en cours', 0,'010.004',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_FREQUENTATION'),'moyenne','Moyenne (accessibilité à pied, proximité PR)','Moyenne (accessibilité à pied, proximité PR)','Moyenne (accessibilité à pied, proximité PR)','monitoring_chiro','Validation en cours', 0,'010.003',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_FREQUENTATION'),'faible','Faible (site peu accessible, peu connu)','Faible (site peu accessible, peu connu)','Faible (site peu accessible, peu connu)','monitoring_chiro','Validation en cours', 0,'010.002',TRUE),
(ref_nomenclatures.get_id_nomenclature_type('CHI_FREQUENTATION'),'nulle','Nulle (pas de pénétrations enthropiques)','Nulle (pas de pénétrations enthropiques)','Nulle (pas de pénétrations enthropiques)','monitoring_chiro','Validation en cours', 0,'010.001',TRUE);
