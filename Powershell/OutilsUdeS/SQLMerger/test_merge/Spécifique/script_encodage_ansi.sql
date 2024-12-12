-- Vue pour le multi occurance de l'écran NO0025B pour les secteurs d'étude
--
-- Programmeur : Réjean Garant
-- Version     : 1.0
-- Date        : 06 janvier 2017
--
create or replace view notation.no0025b_secteur_etude_vue
as
select vse.id,
       app.id                                                       id_programme,
       pv.id                                                        id_programme_version,
       coalesce(apc.id, -1, apc.id)                                 id_cheminement,
       vec.id                                                       id_valeur_element_client,
       vse.vec_secteur_etude,
       app.id_usager_creation,
       app.date_creation,
       app.id_usager_modification,
       app.date_modification
  from programme_activite_pedagogique.programme                       app
  join programme_activite_pedagogique.programme_version               pv  on  app.id                        = pv.id_programme
                                                                          and pv.dernier_vigueur            = 1
  join programme_activite_pedagogique.programme_secteur_etude         vse on  pv.id_programme                         = vse.id_programme
  join gestion_systeme.valeur_element_client                          vec on  vse.id_valeur_element_client_secteur_etude = vec.id
  left join programme_activite_pedagogique.cheminement                apc on  app.id                        = apc.id_programme
where coalesce(apc.id, -1, apc.id) = -1
union all
select vse.id,
       app.id                                                       id_programme,
       pv.id                                                        id_programme_version,
       apc.id                                                       id_cheminement,
       vec.id                                                       id_valeur_element_client,
       vse.vec_secteur_etude,
       app.id_usager_creation,
       app.date_creation,
       app.id_usager_modification,
       app.date_modification
  from programme_activite_pedagogique.programme                 app
  join programme_activite_pedagogique.programme_version         pv  on  app.id                              = pv.id_programme
                                                                    and pv.dernier_vigueur                  = 1
  left join programme_activite_pedagogique.cheminement          apc on  app.id                              = apc.id_programme
  join programme_activite_pedagogique.cheminement_secteur_etude vse on  apc.id                              = vse.id_cheminement
  join gestion_systeme.valeur_element_client                    vec on  vse.id_valeur_element_client_secteur_etude = vec.id
where coalesce(apc.id, -1, apc.id) <> -1;