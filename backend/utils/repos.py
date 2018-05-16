"""
Utilitaires pour simplifier la création ou la mise à jour des données
des entités gn_monitoring

À déplacer à terme dans Geonature/backend/gn_monitoring
"""

from sqlalchemy import and_

from geonature.core.gn_monitoring.models import TBaseSites, corSiteApplication

from geonature.core.gn_commons.repositories import (
    TMediaRepository
)


class InvalidBaseSiteData(Exception):
    pass


class GNMonitoringSiteRepository:
    """
    Création mise à jour des sites gn_monitoring
    """
    def __init__(self, db_sess, id_app):
        """
        params:
            db_sess = session DB initialisée par la vue cliente
        """
        self.session = db_sess
        self.id_app = id_app

    def handle_write(self, *, data=None, base_site_id=None):
        '''
        Opérations d'écriture sur la donnée
        params:
            data = dictionnaire de données filtrées ou pas
            base_site_id facultatif (création d'une nouvelle geom)
        '''
        try:
            if base_site_id is None:
                # nouvelle geom
                model = TBaseSites()
                self.session.add(model)

            else:
                model = self.session.query(TBaseSites).get(base_site_id)
            for field in data:
                if hasattr(model, field):
                    setattr(model, field, data[field])

            self.session.flush()  # génération de l'id de site

            # insertion id application
            app = self.session.query(corSiteApplication).filter(and_(
                corSiteApplication.c.id_base_site == model.id_base_site,
                corSiteApplication.c.id_application == self.id_app)
            ).all()
            if not len(app):
                stmt = corSiteApplication.insert().values(
                    id_base_site=model.id_base_site, id_application=self.id_app
                )
                self.session.execute(stmt)

            return model
        except ValueError: # vérifier type erreur
            raise InvalidBaseSiteData()

    def handle_delete(self, base_site_id):
        '''
        suppression de la donnée
        (ne devrait être utilisé qu'en cas d'erreur de saisie)
        params:
            base_site_id
        Supprime la relation du site à l'application en cours
        Supprime totalement le site s'il n'est plus lié à aucune application
        '''

        # 1 vérifier que le site n'existe pas pour plusieurs applications
        apps = self.session.query(corSiteApplication).filter(corSiteApplication.c.id_base_site==base_site_id).all()
        nb_apps = len(apps)
        if nb_apps == 0:
            # site dans aucune application
            raise InvalidBaseSiteData()

        # 2 : rompre le lien site <-> application
        cur_link = list(filter(lambda x: x[1]==self.id_app, apps))
        if not len(cur_link):
            # site non référencé pour l'application
            raise InvalidBaseSiteData()
        stmt = (corSiteApplication.delete()
                .where(corSiteApplication.c.id_application==self.id_app)
                .where(corSiteApplication.c.id_base_site==base_site_id))
        self.session.execute(stmt)

        # si le site n'existe pas pour une autre application :
        #   3 : supprimer le site
        if nb_apps == 1:
            model = self.session.query(TBaseSites).get(base_site_id)
            self.session.delete(model)
            return True  # vrai en cas de suppression du site

        return False  # faux si le site est juste déréférencé pour l'application


def attach_uuid_to_medium(medium, uuid_attached_row):
    '''
        Fonction permettant de ratacher à posteriori
        une liste de media à une entité
    '''
    for m in medium:
        m['uuid_attached_row'] = uuid_attached_row
        TMediaRepository(m, m['id_media'])._persist_media_db()